<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\PersonalAccessToken;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_register(): void
    {
        $response = $this->postJson('/api/register', [
            'name' => 'Fatima Zahra',
            'phone' => '0612345678',
            'password' => 'password123',
            'city' => 'Casablanca',
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure(['user' => ['id', 'name', 'phone', 'city'], 'token']);

        $this->assertDatabaseHas('users', [
            'phone' => '0612345678',
            'city' => 'Casablanca',
        ]);
    }

    public function test_register_rejects_duplicate_phone(): void
    {
        User::factory()->create(['phone' => '0612345678']);

        $response = $this->postJson('/api/register', [
            'name' => 'Autre Utilisateur',
            'phone' => '0612345678',
            'password' => 'password123',
            'city' => 'Rabat',
        ]);

        $response->assertStatus(422)->assertJsonValidationErrors('phone');
    }

    public function test_user_can_login_with_correct_credentials(): void
    {
        User::factory()->create([
            'phone' => '0612345678',
            'password' => 'password123',
        ]);

        $response = $this->postJson('/api/login', [
            'phone' => '0612345678',
            'password' => 'password123',
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure(['user' => ['id', 'name', 'phone'], 'token']);
    }

    public function test_login_rejects_wrong_password(): void
    {
        User::factory()->create([
            'phone' => '0612345678',
            'password' => 'password123',
        ]);

        $response = $this->postJson('/api/login', [
            'phone' => '0612345678',
            'password' => 'wrong-password',
        ]);

        $response->assertStatus(422)->assertJsonValidationErrors('phone');
    }

    public function test_authenticated_user_can_fetch_me(): void
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->getJson('/api/me');

        $response->assertStatus(200)->assertJson(['id' => $user->id, 'phone' => $user->phone]);
    }

    public function test_unauthenticated_user_cannot_fetch_me(): void
    {
        $response = $this->getJson('/api/me');

        $response->assertStatus(401);
    }

    public function test_logout_deletes_current_token(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('mobile');

        $response = $this->withHeader('Authorization', 'Bearer '.$token->plainTextToken)
            ->postJson('/api/logout');

        $response->assertStatus(200);

        $this->assertNull(PersonalAccessToken::find($token->accessToken->id));
    }
}
