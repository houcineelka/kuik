<?php

namespace Tests\Feature;

use App\Models\Listing;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class ListingClaimTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        Storage::fake('public');
    }

    private function listing(User $owner, string $type): Listing
    {
        return Listing::factory()->create(['user_id' => $owner->id, 'type' => $type, 'status' => 'active']);
    }

    private function claimPayload(array $overrides = []): array
    {
        return array_merge([
            'photo' => UploadedFile::fake()->image('found.jpg'),
            'description' => 'Trouvé près du parc, avec une coque bleue.',
        ], $overrides);
    }

    public function test_claim_on_lost_listing_requires_photo_and_description(): void
    {
        $owner = User::factory()->create();
        $claimant = User::factory()->create();
        $listing = $this->listing($owner, 'lost');

        $response = $this->actingAs($claimant, 'sanctum')
            ->postJson("/api/listings/{$listing->id}/claim", []);

        $response->assertStatus(422)->assertJsonValidationErrors(['photo', 'description']);
        $this->assertDatabaseCount('claims', 0);
    }

    public function test_claim_on_found_listing_requires_photo_and_description(): void
    {
        $owner = User::factory()->create();
        $claimant = User::factory()->create();
        $listing = $this->listing($owner, 'found');

        $response = $this->actingAs($claimant, 'sanctum')
            ->postJson("/api/listings/{$listing->id}/claim", []);

        $response->assertStatus(422)->assertJsonValidationErrors(['photo', 'description']);
        $this->assertDatabaseCount('claims', 0);
    }

    public function test_claim_creates_pending_claim_not_a_conversation(): void
    {
        $owner = User::factory()->create();
        $claimant = User::factory()->create();
        $listing = $this->listing($owner, 'lost');

        $response = $this->actingAs($claimant, 'sanctum')
            ->postJson("/api/listings/{$listing->id}/claim", $this->claimPayload());

        $response->assertStatus(201)->assertJson(['status' => 'pending', 'listing_id' => $listing->id, 'claimant_id' => $claimant->id]);
        $this->assertDatabaseHas('claims', [
            'listing_id' => $listing->id,
            'claimant_id' => $claimant->id,
            'status' => 'pending',
        ]);
        $this->assertDatabaseCount('conversations', 0);
    }

    public function test_second_pending_claim_from_same_claimant_is_rejected(): void
    {
        $owner = User::factory()->create();
        $claimant = User::factory()->create();
        $listing = $this->listing($owner, 'lost');

        $this->actingAs($claimant, 'sanctum')
            ->postJson("/api/listings/{$listing->id}/claim", $this->claimPayload(['description' => 'Première réclamation.']))
            ->assertStatus(201);

        $response = $this->actingAs($claimant, 'sanctum')
            ->postJson("/api/listings/{$listing->id}/claim", $this->claimPayload(['description' => 'Deuxième réclamation.']));

        $response->assertStatus(422)->assertJsonValidationErrors('listing');
        $this->assertDatabaseCount('claims', 1);
    }

    public function test_owner_cannot_claim_own_listing(): void
    {
        $owner = User::factory()->create();
        $listing = $this->listing($owner, 'found');

        $response = $this->actingAs($owner, 'sanctum')
            ->postJson("/api/listings/{$listing->id}/claim", $this->claimPayload());

        $response->assertStatus(403);
        $this->assertDatabaseCount('claims', 0);
    }

    public function test_claim_on_inactive_listing_is_rejected(): void
    {
        $owner = User::factory()->create();
        $claimant = User::factory()->create();
        $listing = Listing::factory()->create(['user_id' => $owner->id, 'type' => 'found', 'status' => 'resolved']);

        $response = $this->actingAs($claimant, 'sanctum')
            ->postJson("/api/listings/{$listing->id}/claim", $this->claimPayload());

        $response->assertStatus(422)->assertJsonValidationErrors('listing');
        $this->assertDatabaseCount('claims', 0);
    }

    public function test_unauthenticated_user_cannot_claim(): void
    {
        $listing = Listing::factory()->create(['type' => 'found']);

        $response = $this->postJson("/api/listings/{$listing->id}/claim", []);

        $response->assertStatus(401);
    }
}
