<?php

namespace App\Policies;

use App\Models\ListingMatch;
use App\Models\User;

class ListingMatchPolicy
{
    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, ListingMatch $match): bool
    {
        return $user->id === $match->lostListing->user_id
            || $user->id === $match->foundListing->user_id;
    }
}
