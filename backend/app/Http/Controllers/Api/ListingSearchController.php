<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Listing\SearchListingsRequest;
use App\Models\Listing;
use Illuminate\Http\JsonResponse;

class ListingSearchController extends Controller
{
    /**
     * Handle the incoming request.
     */
    public function __invoke(SearchListingsRequest $request): JsonResponse
    {
        $query = Listing::query();

        if ($request->filled('category')) {
            $query->where('category', $request->input('category'));
        }

        if ($request->filled('type')) {
            $query->where('type', $request->input('type'));
        }

        if ($request->filled('city')) {
            $query->where('city', $request->input('city'));
        }

        if ($request->filled('neighborhood')) {
            $query->where('neighborhood', $request->input('neighborhood'));
        }

        if ($request->filled('date_from')) {
            $query->whereDate('event_date', '>=', $request->input('date_from'));
        }

        if ($request->filled('date_to')) {
            $query->whereDate('event_date', '<=', $request->input('date_to'));
        }

        if ($request->filled('keyword')) {
            $query->where('description', 'like', '%'.$request->input('keyword').'%');
        }

        if ($request->filled('lat') && $request->filled('lng')) {
            $lat = (float) $request->input('lat');
            $lng = (float) $request->input('lng');

            $query->selectRaw('ST_Distance_Sphere(location, POINT(?, ?)) as distance_m', [$lng, $lat]);

            if ($request->filled('radius_km')) {
                $radiusMeters = (float) $request->input('radius_km') * 1000;
                $query->havingRaw('distance_m <= ?', [$radiusMeters]);
            }

            $query->orderBy('distance_m');
        }

        $listings = $query->with('photos')->paginate(15)->withQueryString();

        return response()->json($listings);
    }
}
