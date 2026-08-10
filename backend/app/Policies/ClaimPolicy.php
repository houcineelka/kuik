<?php

namespace App\Policies;

use App\Models\Claim;
use App\Models\User;

class ClaimPolicy
{
    /**
     * Determine whether the user can accept/reject the claim (only the
     * owner of the listing the claim was made against).
     */
    public function update(User $user, Claim $claim): bool
    {
        return $user->id === $claim->listing->user_id;
    }
}
