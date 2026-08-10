<?php

namespace Tests\Feature;

use App\Models\Claim;
use App\Models\Listing;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ClaimReviewTest extends TestCase
{
    use RefreshDatabase;

    private function pendingClaim(User $owner, User $claimant, array $listingAttributes = []): Claim
    {
        $listing = Listing::factory()->create(array_merge([
            'user_id' => $owner->id,
            'type' => 'lost',
            'status' => 'active',
        ], $listingAttributes));

        return $listing->claims()->create([
            'claimant_id' => $claimant->id,
            'photo_url' => 'https://example.test/claims/photo.jpg',
            'description' => 'Trouvé près du parc.',
            'status' => 'pending',
        ]);
    }

    public function test_owner_sees_pending_claims_on_their_listings(): void
    {
        $owner = User::factory()->create();
        $claimant = User::factory()->create();
        $claim = $this->pendingClaim($owner, $claimant);

        $outsider = User::factory()->create();
        $this->pendingClaim($outsider, User::factory()->create());

        $response = $this->actingAs($owner, 'sanctum')->getJson('/api/claims');

        $response->assertStatus(200);
        $ids = collect($response->json('data'))->pluck('id');
        $this->assertEquals([$claim->id], $ids->all());
    }

    public function test_owner_can_accept_claim_which_opens_a_conversation(): void
    {
        $owner = User::factory()->create();
        $claimant = User::factory()->create();
        $claim = $this->pendingClaim($owner, $claimant);

        $response = $this->actingAs($owner, 'sanctum')->patchJson("/api/claims/{$claim->id}", ['status' => 'accepted']);

        $response->assertStatus(200)->assertJsonPath('claim.status', 'accepted')->assertJsonStructure(['conversation_id']);
        $this->assertDatabaseHas('conversations', [
            'listing_id' => $claim->listing_id,
            'user_one_id' => $owner->id,
            'user_two_id' => $claimant->id,
        ]);
    }

    public function test_owner_can_reject_claim_which_does_not_open_a_conversation(): void
    {
        $owner = User::factory()->create();
        $claimant = User::factory()->create();
        $claim = $this->pendingClaim($owner, $claimant);

        $response = $this->actingAs($owner, 'sanctum')->patchJson("/api/claims/{$claim->id}", ['status' => 'rejected']);

        $response->assertStatus(200)->assertJsonPath('claim.status', 'rejected');
        $this->assertDatabaseCount('conversations', 0);
    }

    public function test_non_owner_cannot_review_claim(): void
    {
        $owner = User::factory()->create();
        $claimant = User::factory()->create();
        $claim = $this->pendingClaim($owner, $claimant);

        $response = $this->actingAs($claimant, 'sanctum')->patchJson("/api/claims/{$claim->id}", ['status' => 'accepted']);

        $response->assertStatus(403);
    }

    public function test_review_rejects_invalid_status(): void
    {
        $owner = User::factory()->create();
        $claimant = User::factory()->create();
        $claim = $this->pendingClaim($owner, $claimant);

        $response = $this->actingAs($owner, 'sanctum')->patchJson("/api/claims/{$claim->id}", ['status' => 'maybe']);

        $response->assertStatus(422)->assertJsonValidationErrors('status');
    }

    public function test_unauthenticated_user_cannot_access_claims(): void
    {
        $owner = User::factory()->create();
        $claimant = User::factory()->create();
        $claim = $this->pendingClaim($owner, $claimant);

        $this->getJson('/api/claims')->assertStatus(401);
        $this->patchJson("/api/claims/{$claim->id}", ['status' => 'accepted'])->assertStatus(401);
    }
}
