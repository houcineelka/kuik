<?php

namespace Tests\Feature;

use App\Models\Listing;
use App\Models\ListingMatch;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ListingMatchTest extends TestCase
{
    use RefreshDatabase;

    // Same reference coordinates verified in ListingSearchTest / MatchingServiceTest.
    private const REF_LAT = 33.5731;

    private const REF_LNG = -7.5898;

    private const NEAR_LAT = 33.5831; // ≈ 1.11km from reference

    private const FAR_LAT = 33.6731; // ≈ 11.12km from reference

    private function foundListingPayload(array $overrides = []): array
    {
        return array_merge([
            'type' => 'found',
            'category' => 'telephone',
            'description' => 'iPhone noir trouve pres du parc, coque bleue',
            'city' => 'Casablanca',
            'neighborhood' => 'Maarif',
            'event_date' => '2026-08-02',
            'lat' => self::NEAR_LAT,
            'lng' => self::REF_LNG,
        ], $overrides);
    }

    public function test_creating_found_listing_matches_existing_active_lost_listing(): void
    {
        $lostOwner = User::factory()->create();
        $lost = Listing::factory()->create([
            'user_id' => $lostOwner->id,
            'type' => 'lost',
            'category' => 'telephone',
            'status' => 'active',
            'description' => 'iPhone noir perdu, coque bleue rayee',
            'event_date' => '2026-08-01',
            'location' => Listing::pointExpression(self::REF_LAT, self::REF_LNG),
        ]);

        $foundOwner = User::factory()->create();

        $response = $this->actingAs($foundOwner, 'sanctum')
            ->postJson('/api/listings', $this->foundListingPayload());

        $response->assertStatus(201);

        $this->assertDatabaseHas('matches', [
            'lost_listing_id' => $lost->id,
            'status' => 'suggested',
        ]);
    }

    public function test_no_match_created_when_score_below_threshold(): void
    {
        $lostOwner = User::factory()->create();
        Listing::factory()->create([
            'user_id' => $lostOwner->id,
            'type' => 'lost',
            'category' => 'cles',
            'status' => 'active',
            'description' => 'Trousseau de cles perdu',
            'event_date' => '2026-06-01',
            'location' => Listing::pointExpression(self::FAR_LAT, self::REF_LNG),
        ]);

        $foundOwner = User::factory()->create();

        $response = $this->actingAs($foundOwner, 'sanctum')->postJson('/api/listings', $this->foundListingPayload([
            'category' => 'telephone',
            'description' => 'iPhone noir trouve',
            'event_date' => '2026-08-02',
            'lat' => self::REF_LAT,
            'lng' => self::REF_LNG,
        ]));

        $response->assertStatus(201);
        $this->assertDatabaseCount('matches', 0);
    }

    public function test_matching_excludes_listings_from_the_same_user(): void
    {
        $user = User::factory()->create();
        Listing::factory()->create([
            'user_id' => $user->id,
            'type' => 'lost',
            'category' => 'telephone',
            'status' => 'active',
            'description' => 'iPhone noir perdu, coque bleue rayee',
            'event_date' => '2026-08-01',
            'location' => Listing::pointExpression(self::REF_LAT, self::REF_LNG),
        ]);

        $response = $this->actingAs($user, 'sanctum')->postJson('/api/listings', $this->foundListingPayload());

        $response->assertStatus(201);
        $this->assertDatabaseCount('matches', 0);
    }

    public function test_get_matches_returns_suggestions_for_users_own_listings(): void
    {
        $user = User::factory()->create();
        $otherUser = User::factory()->create();
        $thirdUser = User::factory()->create();

        $userLost = Listing::factory()->create(['user_id' => $user->id, 'type' => 'lost']);
        $otherFound = Listing::factory()->create(['user_id' => $otherUser->id, 'type' => 'found']);

        $relevantMatch = ListingMatch::create([
            'lost_listing_id' => $userLost->id,
            'found_listing_id' => $otherFound->id,
            'score' => 90,
            'status' => 'suggested',
        ]);

        $unrelatedLost = Listing::factory()->create(['user_id' => $otherUser->id, 'type' => 'lost']);
        $unrelatedFound = Listing::factory()->create(['user_id' => $thirdUser->id, 'type' => 'found']);
        ListingMatch::create([
            'lost_listing_id' => $unrelatedLost->id,
            'found_listing_id' => $unrelatedFound->id,
            'score' => 90,
            'status' => 'suggested',
        ]);

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/matches');

        $response->assertStatus(200)->assertJsonStructure(['data', 'current_page', 'total']);
        $ids = collect($response->json('data'))->pluck('id');

        $this->assertEquals([$relevantMatch->id], $ids->all());
    }

    public function test_owner_can_confirm_a_match(): void
    {
        $lostOwner = User::factory()->create();
        $foundOwner = User::factory()->create();
        $lost = Listing::factory()->create(['user_id' => $lostOwner->id, 'type' => 'lost']);
        $found = Listing::factory()->create(['user_id' => $foundOwner->id, 'type' => 'found']);
        $match = ListingMatch::create([
            'lost_listing_id' => $lost->id,
            'found_listing_id' => $found->id,
            'score' => 90,
            'status' => 'suggested',
        ]);

        $response = $this->actingAs($lostOwner, 'sanctum')
            ->patchJson("/api/matches/{$match->id}", ['status' => 'confirmed']);

        $response->assertStatus(200)->assertJson(['status' => 'confirmed']);
        $this->assertDatabaseHas('matches', ['id' => $match->id, 'status' => 'confirmed']);
    }

    public function test_owner_can_reject_a_match(): void
    {
        $lostOwner = User::factory()->create();
        $foundOwner = User::factory()->create();
        $lost = Listing::factory()->create(['user_id' => $lostOwner->id, 'type' => 'lost']);
        $found = Listing::factory()->create(['user_id' => $foundOwner->id, 'type' => 'found']);
        $match = ListingMatch::create([
            'lost_listing_id' => $lost->id,
            'found_listing_id' => $found->id,
            'score' => 90,
            'status' => 'suggested',
        ]);

        $response = $this->actingAs($foundOwner, 'sanctum')
            ->patchJson("/api/matches/{$match->id}", ['status' => 'rejected']);

        $response->assertStatus(200)->assertJson(['status' => 'rejected']);
    }

    public function test_non_participant_cannot_update_match(): void
    {
        $lostOwner = User::factory()->create();
        $foundOwner = User::factory()->create();
        $outsider = User::factory()->create();
        $lost = Listing::factory()->create(['user_id' => $lostOwner->id, 'type' => 'lost']);
        $found = Listing::factory()->create(['user_id' => $foundOwner->id, 'type' => 'found']);
        $match = ListingMatch::create([
            'lost_listing_id' => $lost->id,
            'found_listing_id' => $found->id,
            'score' => 90,
            'status' => 'suggested',
        ]);

        $response = $this->actingAs($outsider, 'sanctum')
            ->patchJson("/api/matches/{$match->id}", ['status' => 'confirmed']);

        $response->assertStatus(403);
    }

    public function test_unauthenticated_user_cannot_list_or_update_matches(): void
    {
        $this->getJson('/api/matches')->assertStatus(401);

        $lost = Listing::factory()->create(['type' => 'lost']);
        $found = Listing::factory()->create(['type' => 'found']);
        $match = ListingMatch::create([
            'lost_listing_id' => $lost->id,
            'found_listing_id' => $found->id,
            'score' => 90,
            'status' => 'suggested',
        ]);

        $this->patchJson("/api/matches/{$match->id}", ['status' => 'confirmed'])->assertStatus(401);
    }
}
