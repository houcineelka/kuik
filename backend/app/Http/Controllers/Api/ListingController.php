<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Listing\ListingRequest;
use App\Models\Listing;
use App\Services\Matching\MatchingService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Gate;

class ListingController extends Controller
{
    public function index(): JsonResponse
    {
        $listings = Listing::with('photos')->orderByDesc('id')->paginate(15);

        return response()->json($listings);
    }

    public function store(ListingRequest $request, MatchingService $matchingService): JsonResponse
    {
        $data = $request->validated();

        $listing = Listing::create([
            'user_id' => $request->user()->id,
            'type' => $data['type'],
            'category' => $data['category'],
            'description' => $data['description'],
            'location' => Listing::pointExpression((float) $data['lat'], (float) $data['lng']),
            'city' => $data['city'],
            'neighborhood' => $data['neighborhood'] ?? null,
            'event_date' => $data['event_date'],
            'private_detail' => $data['private_detail'] ?? null,
        ]);

        $listing = Listing::with('photos')->findOrFail($listing->id);

        $matchingService->findAndPersistMatches($listing);

        return response()->json($listing, Response::HTTP_CREATED);
    }

    public function show(Listing $listing): JsonResponse
    {
        $listing->load('photos');

        return response()->json($listing);
    }

    public function update(ListingRequest $request, Listing $listing): JsonResponse
    {
        Gate::authorize('update', $listing);

        $data = $request->validated();

        $listing->update([
            'type' => $data['type'],
            'category' => $data['category'],
            'description' => $data['description'],
            'location' => Listing::pointExpression((float) $data['lat'], (float) $data['lng']),
            'city' => $data['city'],
            'neighborhood' => $data['neighborhood'] ?? null,
            'event_date' => $data['event_date'],
            'private_detail' => $data['private_detail'] ?? null,
        ]);

        $listing = Listing::with('photos')->findOrFail($listing->id);

        return response()->json($listing);
    }

    public function destroy(Listing $listing): Response
    {
        Gate::authorize('delete', $listing);

        $listing->delete();

        return response()->noContent();
    }

    public function resolve(Listing $listing): JsonResponse
    {
        Gate::authorize('update', $listing);

        $listing->update(['status' => 'resolved']);
        $listing->load('photos');

        return response()->json($listing);
    }
}
