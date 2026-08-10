<?php

namespace Tests\Feature;

use App\Models\Listing;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class ListingPhotoTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        Storage::fake('public');
    }

    public function test_owner_can_upload_one_to_three_photos(): void
    {
        $user = User::factory()->create();
        $listing = Listing::factory()->create(['user_id' => $user->id]);

        $response = $this->actingAs($user, 'sanctum')->postJson("/api/listings/{$listing->id}/photos", [
            'photos' => [
                UploadedFile::fake()->image('photo1.jpg'),
                UploadedFile::fake()->image('photo2.jpg'),
            ],
        ]);

        $response->assertStatus(201)->assertJsonCount(2, 'photos');
        $this->assertDatabaseCount('listing_photos', 2);
    }

    public function test_upload_rejects_zero_photos(): void
    {
        $user = User::factory()->create();
        $listing = Listing::factory()->create(['user_id' => $user->id]);

        $response = $this->actingAs($user, 'sanctum')->postJson("/api/listings/{$listing->id}/photos", [
            'photos' => [],
        ]);

        $response->assertStatus(422)->assertJsonValidationErrors('photos');
    }

    public function test_upload_rejects_more_than_three_photos_in_one_request(): void
    {
        $user = User::factory()->create();
        $listing = Listing::factory()->create(['user_id' => $user->id]);

        $response = $this->actingAs($user, 'sanctum')->postJson("/api/listings/{$listing->id}/photos", [
            'photos' => [
                UploadedFile::fake()->image('1.jpg'),
                UploadedFile::fake()->image('2.jpg'),
                UploadedFile::fake()->image('3.jpg'),
                UploadedFile::fake()->image('4.jpg'),
            ],
        ]);

        $response->assertStatus(422)->assertJsonValidationErrors('photos');
    }

    public function test_upload_rejects_cumulative_total_over_three(): void
    {
        $user = User::factory()->create();
        $listing = Listing::factory()->create(['user_id' => $user->id]);

        $this->actingAs($user, 'sanctum')->postJson("/api/listings/{$listing->id}/photos", [
            'photos' => [
                UploadedFile::fake()->image('1.jpg'),
                UploadedFile::fake()->image('2.jpg'),
            ],
        ])->assertStatus(201);

        $response = $this->actingAs($user, 'sanctum')->postJson("/api/listings/{$listing->id}/photos", [
            'photos' => [
                UploadedFile::fake()->image('3.jpg'),
                UploadedFile::fake()->image('4.jpg'),
            ],
        ]);

        $response->assertStatus(422)->assertJsonValidationErrors('photos');
        $this->assertDatabaseCount('listing_photos', 2);
    }

    public function test_upload_rejects_non_image_mime(): void
    {
        $user = User::factory()->create();
        $listing = Listing::factory()->create(['user_id' => $user->id]);

        $response = $this->actingAs($user, 'sanctum')->postJson("/api/listings/{$listing->id}/photos", [
            'photos' => [UploadedFile::fake()->create('doc.pdf', 100, 'application/pdf')],
        ]);

        $response->assertStatus(422)->assertJsonValidationErrors('photos.0');
    }

    public function test_upload_rejects_oversized_photo(): void
    {
        $user = User::factory()->create();
        $listing = Listing::factory()->create(['user_id' => $user->id]);

        $response = $this->actingAs($user, 'sanctum')->postJson("/api/listings/{$listing->id}/photos", [
            'photos' => [UploadedFile::fake()->image('big.jpg')->size(6000)],
        ]);

        $response->assertStatus(422)->assertJsonValidationErrors('photos.0');
    }

    public function test_non_owner_cannot_upload_photos(): void
    {
        $owner = User::factory()->create();
        $other = User::factory()->create();
        $listing = Listing::factory()->create(['user_id' => $owner->id]);

        $response = $this->actingAs($other, 'sanctum')->postJson("/api/listings/{$listing->id}/photos", [
            'photos' => [UploadedFile::fake()->image('photo.jpg')],
        ]);

        $response->assertStatus(403);
    }

    public function test_unauthenticated_user_cannot_upload_photos(): void
    {
        $listing = Listing::factory()->create();

        $response = $this->postJson("/api/listings/{$listing->id}/photos", [
            'photos' => [UploadedFile::fake()->image('photo.jpg')],
        ]);

        $response->assertStatus(401);
    }
}
