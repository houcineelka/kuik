<?php

namespace Tests\Feature;

use App\Models\Conversation;
use App\Models\Listing;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ConversationTest extends TestCase
{
    use RefreshDatabase;

    private function conversationBetween(User $owner, User $claimant): Conversation
    {
        $listing = Listing::factory()->create(['user_id' => $owner->id]);

        return Conversation::create([
            'listing_id' => $listing->id,
            'user_one_id' => $owner->id,
            'user_two_id' => $claimant->id,
        ]);
    }

    public function test_user_conversation_list_excludes_conversations_they_are_not_part_of(): void
    {
        $owner = User::factory()->create();
        $claimant = User::factory()->create();
        $outsider = User::factory()->create();

        $mine = $this->conversationBetween($owner, $claimant);
        $this->conversationBetween($outsider, User::factory()->create());

        $response = $this->actingAs($claimant, 'sanctum')->getJson('/api/conversations');

        $response->assertStatus(200);
        $ids = collect($response->json('data'))->pluck('id');

        $this->assertEquals([$mine->id], $ids->all());
    }

    public function test_participant_can_send_and_list_messages(): void
    {
        $owner = User::factory()->create();
        $claimant = User::factory()->create();
        $conversation = $this->conversationBetween($owner, $claimant);

        $send = $this->actingAs($claimant, 'sanctum')
            ->postJson("/api/conversations/{$conversation->id}/messages", ['content' => 'Bonjour, je pense que c\'est le mien.']);

        $send->assertStatus(201)->assertJson(['content' => 'Bonjour, je pense que c\'est le mien.', 'sender_id' => $claimant->id]);

        $list = $this->actingAs($owner, 'sanctum')->getJson("/api/conversations/{$conversation->id}/messages");

        $list->assertStatus(200)->assertJsonCount(1, 'data');
    }

    public function test_messages_are_returned_in_chronological_order(): void
    {
        $owner = User::factory()->create();
        $claimant = User::factory()->create();
        $conversation = $this->conversationBetween($owner, $claimant);

        $conversation->messages()->create(['sender_id' => $owner->id, 'content' => 'Premier message']);
        $conversation->messages()->create(['sender_id' => $claimant->id, 'content' => 'Deuxieme message']);
        $conversation->messages()->create(['sender_id' => $owner->id, 'content' => 'Troisieme message']);

        $response = $this->actingAs($owner, 'sanctum')->getJson("/api/conversations/{$conversation->id}/messages");

        $response->assertStatus(200);
        $contents = collect($response->json('data'))->pluck('content')->all();

        $this->assertEquals(['Premier message', 'Deuxieme message', 'Troisieme message'], $contents);
    }

    public function test_fetching_messages_marks_others_messages_as_read(): void
    {
        $owner = User::factory()->create();
        $claimant = User::factory()->create();
        $conversation = $this->conversationBetween($owner, $claimant);

        $ownMessage = $conversation->messages()->create(['sender_id' => $owner->id, 'content' => 'De moi']);
        $theirMessage = $conversation->messages()->create(['sender_id' => $claimant->id, 'content' => 'D\'eux']);

        $this->actingAs($owner, 'sanctum')->getJson("/api/conversations/{$conversation->id}/messages")->assertStatus(200);

        $this->assertNull($ownMessage->fresh()->read_at);
        $this->assertNotNull($theirMessage->fresh()->read_at);
    }

    public function test_conversation_list_reports_unread_count_per_conversation(): void
    {
        $owner = User::factory()->create();
        $claimant = User::factory()->create();
        $conversation = $this->conversationBetween($owner, $claimant);

        $conversation->messages()->create(['sender_id' => $claimant->id, 'content' => 'Un']);
        $conversation->messages()->create(['sender_id' => $claimant->id, 'content' => 'Deux']);
        $conversation->messages()->create(['sender_id' => $owner->id, 'content' => 'Ma reponse']);

        $response = $this->actingAs($owner, 'sanctum')->getJson('/api/conversations');

        $response->assertStatus(200)->assertJsonPath('data.0.unread_count', 2);

        $this->actingAs($owner, 'sanctum')->getJson("/api/conversations/{$conversation->id}/messages");

        $afterRead = $this->actingAs($owner, 'sanctum')->getJson('/api/conversations');
        $afterRead->assertStatus(200)->assertJsonPath('data.0.unread_count', 0);
    }

    public function test_non_participant_cannot_read_messages(): void
    {
        $owner = User::factory()->create();
        $claimant = User::factory()->create();
        $outsider = User::factory()->create();
        $conversation = $this->conversationBetween($owner, $claimant);

        $response = $this->actingAs($outsider, 'sanctum')->getJson("/api/conversations/{$conversation->id}/messages");

        $response->assertStatus(403);
    }

    public function test_non_participant_cannot_send_messages(): void
    {
        $owner = User::factory()->create();
        $claimant = User::factory()->create();
        $outsider = User::factory()->create();
        $conversation = $this->conversationBetween($owner, $claimant);

        $response = $this->actingAs($outsider, 'sanctum')
            ->postJson("/api/conversations/{$conversation->id}/messages", ['content' => 'Je m\'incruste']);

        $response->assertStatus(403);
    }

    public function test_unauthenticated_user_cannot_access_conversations(): void
    {
        $owner = User::factory()->create();
        $claimant = User::factory()->create();
        $conversation = $this->conversationBetween($owner, $claimant);

        $this->getJson('/api/conversations')->assertStatus(401);
        $this->getJson("/api/conversations/{$conversation->id}/messages")->assertStatus(401);
        $this->postJson("/api/conversations/{$conversation->id}/messages", ['content' => 'x'])->assertStatus(401);
    }
}
