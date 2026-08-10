<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Listing\UpdateListingMatchRequest;
use App\Models\ListingMatch;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class ListingMatchController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $userId = $request->user()->id;

        $matches = ListingMatch::query()
            ->where('status', 'suggested')
            ->where(function ($query) use ($userId) {
                $query->whereHas('lostListing', fn ($q) => $q->where('user_id', $userId))
                    ->orWhereHas('foundListing', fn ($q) => $q->where('user_id', $userId));
            })
            ->with(['lostListing.photos', 'foundListing.photos'])
            ->orderByDesc('score')
            ->paginate(15);

        return response()->json($matches);
    }

    public function update(UpdateListingMatchRequest $request, ListingMatch $match): JsonResponse
    {
        Gate::authorize('update', $match);

        $match->update(['status' => $request->validated()['status']]);
        $match->load(['lostListing.photos', 'foundListing.photos']);

        return response()->json($match);
    }
}
