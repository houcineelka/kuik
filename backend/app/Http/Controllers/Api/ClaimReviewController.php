<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Listing\UpdateClaimRequest;
use App\Models\Claim;
use App\Models\Conversation;
use App\Services\Notifications\FcmService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class ClaimReviewController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $userId = $request->user()->id;

        $claims = Claim::query()
            ->where('status', 'pending')
            ->whereHas('listing', fn ($query) => $query->where('user_id', $userId))
            ->with(['listing.photos', 'claimant'])
            ->orderByDesc('created_at')
            ->paginate(15);

        return response()->json($claims);
    }

    public function update(UpdateClaimRequest $request, Claim $claim, FcmService $fcmService): JsonResponse
    {
        Gate::authorize('update', $claim);

        $status = $request->validated()['status'];
        $claim->update(['status' => $status]);
        $claim->loadMissing(['listing', 'claimant']);

        if ($status === 'accepted') {
            $conversation = Conversation::firstOrCreate([
                'listing_id' => $claim->listing_id,
                'user_one_id' => $claim->listing->user_id,
                'user_two_id' => $claim->claimant_id,
            ]);

            $fcmService->sendToUser($claim->claimant, 'Réclamation acceptée', 'Le propriétaire a accepté votre réclamation.', [
                'type' => 'claim_accepted',
                'conversation_id' => (string) $conversation->id,
            ]);

            return response()->json(['claim' => $claim, 'conversation_id' => $conversation->id]);
        }

        $fcmService->sendToUser($claim->claimant, 'Réclamation refusée', 'Le propriétaire a refusé votre réclamation.', [
            'type' => 'claim_rejected',
            'listing_id' => (string) $claim->listing_id,
        ]);

        return response()->json(['claim' => $claim]);
    }
}
