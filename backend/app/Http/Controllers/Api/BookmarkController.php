<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Bookmark;
use App\Models\Listing;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class BookmarkController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $bookmarks = Bookmark::with('listing.photos')
            ->where('user_id', $request->user()->id)
            ->orderByDesc('created_at')
            ->paginate(15);

        $bookmarks->setCollection($bookmarks->getCollection()->map->listing);

        return response()->json($bookmarks);
    }

    public function store(Request $request, Listing $listing): JsonResponse
    {
        Bookmark::firstOrCreate([
            'user_id' => $request->user()->id,
            'listing_id' => $listing->id,
        ]);

        return response()->json(['bookmarked' => true], Response::HTTP_CREATED);
    }

    public function destroy(Request $request, Listing $listing): Response
    {
        Bookmark::where('user_id', $request->user()->id)
            ->where('listing_id', $listing->id)
            ->delete();

        return response()->noContent();
    }
}
