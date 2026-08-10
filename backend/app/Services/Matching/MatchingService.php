<?php

namespace App\Services\Matching;

use App\Models\Listing;
use App\Models\ListingMatch;
use App\Services\Notifications\FcmService;
use Illuminate\Support\Collection;

class MatchingService
{
    public function __construct(private FcmService $fcmService = new FcmService())
    {
    }

    /**
     * Pure scoring function: no DB access, operates only on attributes already
     * present on the given Listing instances. Returns a 0-100 score.
     */
    public function score(Listing $a, Listing $b): float
    {
        $weights = config('matching.weights');

        $categoryScore = $a->category === $b->category ? $weights['category'] : 0.0;

        $distanceKm = $this->haversineKm(
            (float) $a->latitude, (float) $a->longitude,
            (float) $b->latitude, (float) $b->longitude,
        );
        $distanceScore = $this->decay($distanceKm, (float) config('matching.distance_threshold_km')) * $weights['distance'];

        $daysDiff = abs($a->event_date->diffInDays($b->event_date));
        $dateScore = $this->decay((float) $daysDiff, (float) config('matching.date_window_days')) * $weights['date'];

        $descriptionScore = $this->descriptionSimilarity((string) $a->description, (string) $b->description) * $weights['description'];

        return $categoryScore + $distanceScore + $dateScore + $descriptionScore;
    }

    /**
     * Compares the given listing against all active listings of the opposite
     * type (excluding the listing's own owner), persists matches above the
     * configured threshold, and notifies for each newly created match.
     *
     * @return Collection<int, ListingMatch>
     */
    public function findAndPersistMatches(Listing $listing): Collection
    {
        $oppositeType = $listing->type === 'lost' ? 'found' : 'lost';

        $candidates = Listing::query()
            ->where('type', $oppositeType)
            ->where('status', 'active')
            ->where('user_id', '!=', $listing->user_id)
            ->get();

        $threshold = (float) config('matching.match_threshold');
        $created = new Collection();

        foreach ($candidates as $candidate) {
            $score = $this->score($listing, $candidate);

            if ($score < $threshold) {
                continue;
            }

            [$lost, $found] = $listing->type === 'lost'
                ? [$listing, $candidate]
                : [$candidate, $listing];

            $match = ListingMatch::firstOrCreate(
                ['lost_listing_id' => $lost->id, 'found_listing_id' => $found->id],
                ['score' => $score, 'status' => 'suggested']
            );

            if ($match->wasRecentlyCreated) {
                $this->notifyMatch($match);
                $created->push($match);
            }
        }

        return $created;
    }

    protected function notifyMatch(ListingMatch $match): void
    {
        $match->loadMissing(['lostListing.user', 'foundListing.user']);

        $title = 'Correspondance trouvée';
        $body = 'Une annonce correspond peut-être à la vôtre.';
        $data = ['type' => 'match', 'match_id' => (string) $match->id];

        $this->fcmService->sendToUser($match->lostListing->user, $title, $body, $data);
        $this->fcmService->sendToUser($match->foundListing->user, $title, $body, $data);
    }

    /**
     * Linear decay to 0 at $threshold, capped at [0,1].
     */
    private function decay(float $value, float $threshold): float
    {
        if ($threshold <= 0) {
            return $value <= 0 ? 1.0 : 0.0;
        }

        return max(0.0, 1.0 - ($value / $threshold));
    }

    private function haversineKm(float $lat1, float $lng1, float $lat2, float $lng2): float
    {
        $earthRadiusKm = 6371.0;

        $latDelta = deg2rad($lat2 - $lat1);
        $lngDelta = deg2rad($lng2 - $lng1);

        $h = sin($latDelta / 2) ** 2
            + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * sin($lngDelta / 2) ** 2;

        return $earthRadiusKm * 2 * asin(min(1.0, sqrt($h)));
    }

    private function descriptionSimilarity(string $a, string $b): float
    {
        $tokensA = $this->tokenize($a);
        $tokensB = $this->tokenize($b);

        if (empty($tokensA) || empty($tokensB)) {
            return 0.0;
        }

        $intersection = count(array_intersect($tokensA, $tokensB));
        $union = count(array_unique(array_merge($tokensA, $tokensB)));

        return $union > 0 ? $intersection / $union : 0.0;
    }

    /**
     * @return list<string>
     */
    private function tokenize(string $text): array
    {
        $normalized = mb_strtolower($text);
        $normalized = preg_replace('/[^\p{L}\p{N}\s]/u', ' ', $normalized) ?? '';
        $tokens = preg_split('/\s+/', trim($normalized), -1, PREG_SPLIT_NO_EMPTY) ?: [];

        return array_values(array_unique($tokens));
    }
}
