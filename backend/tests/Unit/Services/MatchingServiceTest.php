<?php

namespace Tests\Unit\Services;

use App\Models\Listing;
use App\Services\Matching\MatchingService;
use Tests\TestCase;

class MatchingServiceTest extends TestCase
{
    // Reference point, verified against MariaDB's ST_Distance_Sphere in ListingSearchTest:
    // +0.01 lat ≈ 1.11km away, +0.1 lat ≈ 11.12km away (well beyond the 5km default threshold).
    private const REF_LAT = 33.5731;

    private const REF_LNG = -7.5898;

    private const NEAR_LAT = 33.5831;

    private const FAR_LAT = 33.6731;

    private function listing(string $category, float $lat, float $lng, string $eventDate, string $description): Listing
    {
        $listing = new Listing([
            'category' => $category,
            'description' => $description,
            'event_date' => $eventDate,
        ]);
        $listing->latitude = $lat;
        $listing->longitude = $lng;

        return $listing;
    }

    public function test_same_category_close_distance_close_date_scores_high(): void
    {
        $a = $this->listing('telephone', self::REF_LAT, self::REF_LNG, '2026-08-01', 'iPhone noir avec coque bleue');
        $b = $this->listing('telephone', self::REF_LAT, self::REF_LNG, '2026-08-01', 'iPhone noir trouve coque bleue');

        $score = (new MatchingService())->score($a, $b);

        $this->assertGreaterThanOrEqual(80, $score);
    }

    public function test_different_category_scores_lower_than_same_category(): void
    {
        $sameCategoryA = $this->listing('telephone', self::REF_LAT, self::REF_LNG, '2026-08-01', 'iPhone noir avec coque bleue');
        $sameCategoryB = $this->listing('telephone', self::REF_LAT, self::REF_LNG, '2026-08-01', 'iPhone noir trouve coque bleue');
        $differentCategoryB = $this->listing('cles', self::REF_LAT, self::REF_LNG, '2026-08-01', 'iPhone noir trouve coque bleue');

        $service = new MatchingService();
        $scoreSameCategory = $service->score($sameCategoryA, $sameCategoryB);
        $scoreDifferentCategory = $service->score($sameCategoryA, $differentCategoryB);

        $this->assertTrue($scoreDifferentCategory < $scoreSameCategory - 20);
    }

    public function test_far_distance_reduces_score(): void
    {
        $reference = $this->listing('telephone', self::REF_LAT, self::REF_LNG, '2026-08-01', 'iPhone noir avec coque bleue');
        $close = $this->listing('telephone', self::REF_LAT, self::REF_LNG, '2026-08-01', 'iPhone noir trouve coque bleue');
        $far = $this->listing('telephone', self::FAR_LAT, self::REF_LNG, '2026-08-01', 'iPhone noir trouve coque bleue');

        $service = new MatchingService();
        $scoreClose = $service->score($reference, $close);
        $scoreFar = $service->score($reference, $far);

        $this->assertTrue($scoreFar <= $scoreClose - 25);
    }

    public function test_mismatched_listing_scores_below_default_threshold(): void
    {
        $a = $this->listing('telephone', self::REF_LAT, self::REF_LNG, '2026-08-01', 'iPhone noir avec coque bleue');
        $b = $this->listing('cles', self::FAR_LAT, self::REF_LNG, '2026-08-31', 'Trousseau de cles perdu');

        $score = (new MatchingService())->score($a, $b);

        $this->assertLessThan((float) config('matching.match_threshold'), $score);
    }
}
