<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Listing\ClaimListingRequest;
use App\Models\Listing;
use App\Services\Notifications\FcmService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;

class ListingClaimController extends Controller
{
    /**
     * Every claim — "I found this" on a lost listing, or "this is mine" on
     * a found listing — submits photo proof + a short description instead
     * of unlocking a conversation immediately. The listing owner reviews it
     * via GET/PATCH /claims before any chat opens.
     */
    public function store(ClaimListingRequest $request, Listing $listing, FcmService $fcmService): JsonResponse
    {
        Gate::authorize('claim', $listing);

        if ($listing->status !== 'active') {
            throw ValidationException::withMessages([
                'listing' => ["Cette annonce n'est plus active."],
            ]);
        }

        $user = $request->user();

        $alreadyPending = $listing->claims()
            ->where('claimant_id', $user->id)
            ->where('status', 'pending')
            ->exists();

        if ($alreadyPending) {
            throw ValidationException::withMessages([
                'listing' => ['Vous avez déjà une réclamation en attente pour cette annonce.'],
            ]);
        }

        $path = $request->file('photo')->store("claims/{$listing->id}", 'public');

        $claim = $listing->claims()->create([
            'claimant_id' => $user->id,
            'photo_url' => Storage::disk('public')->url($path),
            'description' => $request->validated()['description'],
            'status' => 'pending',
        ]);

        $listing->loadMissing('user');
        $fcmService->sendToUser($listing->user, 'Nouvelle réclamation sur votre annonce', $claim->description, [
            'type' => 'claim',
            'claim_id' => (string) $claim->id,
        ]);

        return response()->json($claim, Response::HTTP_CREATED);
    }
}
