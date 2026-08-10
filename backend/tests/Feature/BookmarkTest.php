<?php

namespace Tests\Feature;

use App\Models\Bookmark;
use App\Models\Listing;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class BookmarkTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_bookmark_a_listing(): void
    {
        $user = User::factory()->create();
        $listing = Listing::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->postJson("/api/listings/{$listing->id}/bookmark");

        $response->assertStatus(201);
        $this->assertDatabaseHas('bookmarks', ['user_id' => $user->id, 'listing_id' => $listing->id]);
    }

    public function test_bookmarking_the_same_listing_twice_is_idempotent(): void
    {
        $user = User::factory()->create();
        $listing = Listing::factory()->create();

        $this->actingAs($user, 'sanctum')->postJson("/api/listings/{$listing->id}/bookmark")->assertStatus(201);
        $this->actingAs($user, 'sanctum')->postJson("/api/listings/{$listing->id}/bookmark")->assertStatus(201);

        $this->assertDatabaseCount('bookmarks', 1);
    }

    public function test_user_can_remove_a_bookmark(): void
    {
        $user = User::factory()->create();
        $listing = Listing::factory()->create();
        Bookmark::create(['user_id' => $user->id, 'listing_id' => $listing->id]);

        $response = $this->actingAs($user, 'sanctum')->deleteJson("/api/listings/{$listing->id}/bookmark");

        $response->assertStatus(204);
        $this->assertDatabaseCount('bookmarks', 0);
    }

    public function test_user_bookmark_list_excludes_other_users_bookmarks(): void
    {
        $user = User::factory()->create();
        $other = User::factory()->create();
        $mine = Listing::factory()->create();
        $notMine = Listing::factory()->create();

        Bookmark::create(['user_id' => $user->id, 'listing_id' => $mine->id]);
        Bookmark::create(['user_id' => $other->id, 'listing_id' => $notMine->id]);

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/bookmarks');

        $response->assertStatus(200);
        $ids = collect($response->json('data'))->pluck('id');
        $this->assertEquals([$mine->id], $ids->all());
    }

    public function test_bookmark_list_is_ordered_most_recently_bookmarked_first(): void
    {
        $user = User::factory()->create();
        $first = Listing::factory()->create();
        $second = Listing::factory()->create();

        Bookmark::create(['user_id' => $user->id, 'listing_id' => $first->id])
            ->forceFill(['created_at' => now()->subMinute()])->save();
        Bookmark::create(['user_id' => $user->id, 'listing_id' => $second->id])
            ->forceFill(['created_at' => now()])->save();

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/bookmarks');

        $ids = collect($response->json('data'))->pluck('id');
        $this->assertEquals([$second->id, $first->id], $ids->all());
    }

    public function test_unauthenticated_user_cannot_access_bookmarks(): void
    {
        $listing = Listing::factory()->create();

        $this->getJson('/api/bookmarks')->assertStatus(401);
        $this->postJson("/api/listings/{$listing->id}/bookmark")->assertStatus(401);
        $this->deleteJson("/api/listings/{$listing->id}/bookmark")->assertStatus(401);
    }
}
