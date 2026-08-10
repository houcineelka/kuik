<?php

namespace Tests\Feature;

use App\Models\DeviceToken;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DeviceTokenTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_register_a_device_token(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->postJson('/api/device-tokens', [
            'token' => 'token-abc',
            'platform' => 'android',
        ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('device_tokens', [
            'user_id' => $user->id,
            'token' => 'token-abc',
            'platform' => 'android',
        ]);
    }

    public function test_registering_an_existing_token_repoints_it_to_the_new_user(): void
    {
        $previousOwner = User::factory()->create();
        $newOwner = User::factory()->create();
        DeviceToken::create(['user_id' => $previousOwner->id, 'token' => 'shared-token', 'platform' => 'android']);

        $response = $this->actingAs($newOwner, 'sanctum')->postJson('/api/device-tokens', [
            'token' => 'shared-token',
            'platform' => 'android',
        ]);

        $response->assertStatus(201);
        $this->assertDatabaseCount('device_tokens', 1);
        $this->assertDatabaseHas('device_tokens', ['token' => 'shared-token', 'user_id' => $newOwner->id]);
    }

    public function test_registration_validates_platform(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->postJson('/api/device-tokens', [
            'token' => 'token-abc',
            'platform' => 'windows',
        ]);

        $response->assertStatus(422);
    }

    public function test_user_can_unregister_a_device_token(): void
    {
        $user = User::factory()->create();
        DeviceToken::create(['user_id' => $user->id, 'token' => 'token-abc', 'platform' => 'android']);

        $response = $this->actingAs($user, 'sanctum')->deleteJson('/api/device-tokens?token=token-abc');

        $response->assertStatus(204);
        $this->assertDatabaseCount('device_tokens', 0);
    }

    public function test_unauthenticated_user_cannot_manage_device_tokens(): void
    {
        $this->postJson('/api/device-tokens', ['token' => 'x', 'platform' => 'android'])->assertStatus(401);
        $this->deleteJson('/api/device-tokens?token=x')->assertStatus(401);
    }
}
