<?php

namespace Database\Factories;

use App\Models\Listing;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Listing>
 */
class ListingFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'type' => fake()->randomElement(['lost', 'found']),
            'category' => fake()->randomElement(['telephone', 'cles', 'portefeuille', 'sac', 'autre']),
            'description' => fake()->sentence(),
            'location' => Listing::pointExpression(fake()->latitude(30, 36), fake()->longitude(-10, -1)),
            'city' => fake()->city(),
            'neighborhood' => fake()->streetName(),
            'event_date' => fake()->dateTimeBetween('-30 days', 'now')->format('Y-m-d'),
            'private_detail' => null,
            'status' => 'active',
        ];
    }
}
