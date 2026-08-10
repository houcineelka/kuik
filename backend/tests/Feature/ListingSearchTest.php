<?php

namespace Tests\Feature;

use App\Models\Listing;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ListingSearchTest extends TestCase
{
    use RefreshDatabase;

    // Reference point, verified against MariaDB's ST_Distance_Sphere:
    // +0.01 lat ≈ 1112m away, +0.1 lat ≈ 11119m away.
    private const REF_LAT = 33.5731;

    private const REF_LNG = -7.5898;

    private const NEAR_LAT = 33.5831; // ≈ 1.11km from reference

    private const FAR_LAT = 33.6731; // ≈ 11.12km from reference

    private function authedUser(): User
    {
        return User::factory()->create();
    }

    public function test_radius_search_excludes_listings_outside_radius(): void
    {
        $user = $this->authedUser();

        $near = Listing::factory()->create([
            'user_id' => $user->id,
            'type' => 'found',
            'location' => Listing::pointExpression(self::NEAR_LAT, self::REF_LNG),
        ]);
        $far = Listing::factory()->create([
            'user_id' => $user->id,
            'type' => 'found',
            'location' => Listing::pointExpression(self::FAR_LAT, self::REF_LNG),
        ]);

        $response = $this->actingAs($user, 'sanctum')->getJson(
            '/api/listings/search?'.http_build_query([
                'lat' => self::REF_LAT,
                'lng' => self::REF_LNG,
                'radius_km' => 5,
            ])
        );

        $response->assertStatus(200);
        $ids = collect($response->json('data'))->pluck('id');

        $this->assertTrue($ids->contains($near->id));
        $this->assertFalse($ids->contains($far->id));
    }

    public function test_search_sorts_by_distance_ascending(): void
    {
        $user = $this->authedUser();

        $far = Listing::factory()->create([
            'user_id' => $user->id,
            'location' => Listing::pointExpression(self::FAR_LAT, self::REF_LNG),
        ]);
        $near = Listing::factory()->create([
            'user_id' => $user->id,
            'location' => Listing::pointExpression(self::NEAR_LAT, self::REF_LNG),
        ]);

        $response = $this->actingAs($user, 'sanctum')->getJson(
            '/api/listings/search?'.http_build_query([
                'lat' => self::REF_LAT,
                'lng' => self::REF_LNG,
            ])
        );

        $response->assertStatus(200);
        $ids = collect($response->json('data'))->pluck('id')->values();

        $this->assertEquals($near->id, $ids->first());
        $this->assertEquals($far->id, $ids->last());
    }

    public function test_search_combines_category_type_and_radius_filters(): void
    {
        $user = $this->authedUser();

        $match = Listing::factory()->create([
            'user_id' => $user->id,
            'category' => 'telephone',
            'type' => 'found',
            'location' => Listing::pointExpression(self::NEAR_LAT, self::REF_LNG),
        ]);
        // Wrong category, otherwise identical.
        Listing::factory()->create([
            'user_id' => $user->id,
            'category' => 'cles',
            'type' => 'found',
            'location' => Listing::pointExpression(self::NEAR_LAT, self::REF_LNG),
        ]);
        // Wrong type, otherwise identical.
        Listing::factory()->create([
            'user_id' => $user->id,
            'category' => 'telephone',
            'type' => 'lost',
            'location' => Listing::pointExpression(self::NEAR_LAT, self::REF_LNG),
        ]);
        // Right category/type, but outside the radius.
        Listing::factory()->create([
            'user_id' => $user->id,
            'category' => 'telephone',
            'type' => 'found',
            'location' => Listing::pointExpression(self::FAR_LAT, self::REF_LNG),
        ]);

        $response = $this->actingAs($user, 'sanctum')->getJson(
            '/api/listings/search?'.http_build_query([
                'lat' => self::REF_LAT,
                'lng' => self::REF_LNG,
                'radius_km' => 5,
                'category' => 'telephone',
                'type' => 'found',
            ])
        );

        $response->assertStatus(200);
        $ids = collect($response->json('data'))->pluck('id');

        $this->assertEquals([$match->id], $ids->all());
    }

    public function test_search_filters_by_city(): void
    {
        $user = $this->authedUser();

        $casablanca = Listing::factory()->create(['user_id' => $user->id, 'city' => 'Casablanca']);
        Listing::factory()->create(['user_id' => $user->id, 'city' => 'Rabat']);

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/listings/search?city=Casablanca');

        $response->assertStatus(200);
        $ids = collect($response->json('data'))->pluck('id');

        $this->assertEquals([$casablanca->id], $ids->all());
    }

    public function test_search_filters_by_keyword(): void
    {
        $user = $this->authedUser();

        $matching = Listing::factory()->create(['user_id' => $user->id, 'description' => 'iPhone noir avec coque bleue']);
        Listing::factory()->create(['user_id' => $user->id, 'description' => 'Trousseau de clés']);

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/listings/search?keyword=iPhone');

        $response->assertStatus(200);
        $ids = collect($response->json('data'))->pluck('id');

        $this->assertEquals([$matching->id], $ids->all());
    }

    public function test_search_filters_by_date_range(): void
    {
        $user = $this->authedUser();

        $inRange = Listing::factory()->create(['user_id' => $user->id, 'event_date' => '2026-08-05']);
        Listing::factory()->create(['user_id' => $user->id, 'event_date' => '2026-07-01']);

        $response = $this->actingAs($user, 'sanctum')->getJson(
            '/api/listings/search?'.http_build_query(['date_from' => '2026-08-01', 'date_to' => '2026-08-10'])
        );

        $response->assertStatus(200);
        $ids = collect($response->json('data'))->pluck('id');

        $this->assertEquals([$inRange->id], $ids->all());
    }

    public function test_lat_requires_lng(): void
    {
        $user = $this->authedUser();

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/listings/search?lat=33.5');

        $response->assertStatus(422)->assertJsonValidationErrors('lng');
    }

    public function test_radius_km_requires_coordinates(): void
    {
        $user = $this->authedUser();

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/listings/search?radius_km=5');

        $response->assertStatus(422)->assertJsonValidationErrors(['lat', 'lng']);
    }

    public function test_unauthenticated_user_cannot_search(): void
    {
        $response = $this->getJson('/api/listings/search');

        $response->assertStatus(401);
    }
}
