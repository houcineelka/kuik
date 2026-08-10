<?php

namespace Tests\Feature;

use App\Models\Listing;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ListingTest extends TestCase
{
    use RefreshDatabase;

    private function validPayload(array $overrides = []): array
    {
        return array_merge([
            'type' => 'lost',
            'category' => 'telephone',
            'description' => 'iPhone noir perdu près du parc',
            'city' => 'Casablanca',
            'neighborhood' => 'Maarif',
            'event_date' => '2026-08-01',
            'private_detail' => 'Coque avec une rayure sur le coin',
            'lat' => 33.5731,
            'lng' => -7.5898,
        ], $overrides);
    }

    public function test_authenticated_user_can_create_listing(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/listings', $this->validPayload());

        $response->assertStatus(201)
            ->assertJson([
                'user_id' => $user->id,
                'type' => 'lost',
                'category' => 'telephone',
                'city' => 'Casablanca',
                'status' => 'active',
                'latitude' => 33.5731,
                'longitude' => -7.5898,
                'photos' => [],
            ]);

        $this->assertDatabaseHas('listings', [
            'user_id' => $user->id,
            'category' => 'telephone',
        ]);
    }

    public function test_unauthenticated_user_cannot_create_listing(): void
    {
        $response = $this->postJson('/api/listings', $this->validPayload());

        $response->assertStatus(401);
    }

    public function test_create_listing_validates_required_fields(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->postJson('/api/listings', []);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['type', 'category', 'description', 'city', 'event_date', 'lat', 'lng']);
    }

    public function test_listings_index_is_paginated_and_includes_photos(): void
    {
        $user = User::factory()->create();
        Listing::factory()->count(3)->create(['user_id' => $user->id]);

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/listings');

        $response->assertStatus(200)
            ->assertJsonStructure(['data', 'current_page', 'total', 'per_page'])
            ->assertJsonCount(3, 'data')
            ->assertJsonStructure(['data' => [['id', 'latitude', 'longitude', 'photos']]]);
    }

    public function test_show_returns_listing_detail(): void
    {
        $user = User::factory()->create();
        $listing = Listing::factory()->create(['user_id' => $user->id]);

        $response = $this->actingAs($user, 'sanctum')->getJson("/api/listings/{$listing->id}");

        $response->assertStatus(200)->assertJson(['id' => $listing->id]);
    }

    public function test_owner_can_update_listing_and_coordinates_reflect_new_values(): void
    {
        $user = User::factory()->create();
        $listing = Listing::factory()->create(['user_id' => $user->id]);

        $response = $this->actingAs($user, 'sanctum')
            ->putJson("/api/listings/{$listing->id}", $this->validPayload([
                'lat' => 34.0209,
                'lng' => -6.8416,
            ]));

        $response->assertStatus(200)
            ->assertJson(['latitude' => 34.0209, 'longitude' => -6.8416]);
    }

    public function test_non_owner_cannot_update_listing(): void
    {
        $owner = User::factory()->create();
        $other = User::factory()->create();
        $listing = Listing::factory()->create(['user_id' => $owner->id]);

        $response = $this->actingAs($other, 'sanctum')
            ->putJson("/api/listings/{$listing->id}", $this->validPayload());

        $response->assertStatus(403);
    }

    public function test_owner_can_delete_listing(): void
    {
        $user = User::factory()->create();
        $listing = Listing::factory()->create(['user_id' => $user->id]);

        $response = $this->actingAs($user, 'sanctum')->deleteJson("/api/listings/{$listing->id}");

        $response->assertStatus(204);
        $this->assertDatabaseMissing('listings', ['id' => $listing->id]);
    }

    public function test_non_owner_cannot_delete_listing(): void
    {
        $owner = User::factory()->create();
        $other = User::factory()->create();
        $listing = Listing::factory()->create(['user_id' => $owner->id]);

        $response = $this->actingAs($other, 'sanctum')->deleteJson("/api/listings/{$listing->id}");

        $response->assertStatus(403);
        $this->assertDatabaseHas('listings', ['id' => $listing->id]);
    }

    public function test_owner_can_resolve_listing(): void
    {
        $user = User::factory()->create();
        $listing = Listing::factory()->create(['user_id' => $user->id, 'status' => 'active']);

        $response = $this->actingAs($user, 'sanctum')->patchJson("/api/listings/{$listing->id}/resolve");

        $response->assertStatus(200)->assertJson(['status' => 'resolved']);
    }

    public function test_non_owner_cannot_resolve_listing(): void
    {
        $owner = User::factory()->create();
        $other = User::factory()->create();
        $listing = Listing::factory()->create(['user_id' => $owner->id]);

        $response = $this->actingAs($other, 'sanctum')->patchJson("/api/listings/{$listing->id}/resolve");

        $response->assertStatus(403);
    }
}
