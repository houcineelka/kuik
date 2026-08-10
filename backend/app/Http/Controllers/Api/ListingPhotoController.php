<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Listing\StorePhotosRequest;
use App\Models\Listing;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Storage;

class ListingPhotoController extends Controller
{
    public function store(StorePhotosRequest $request, Listing $listing): JsonResponse
    {
        Gate::authorize('update', $listing);

        foreach ($request->file('photos', []) as $photo) {
            $path = $photo->store("listings/{$listing->id}", 'public');

            $listing->photos()->create([
                'photo_url' => Storage::disk('public')->url($path),
            ]);
        }

        $listing = Listing::with('photos')->findOrFail($listing->id);

        return response()->json($listing, Response::HTTP_CREATED);
    }
}
