<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\DeviceToken\StoreDeviceTokenRequest;
use App\Models\DeviceToken;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class DeviceTokenController extends Controller
{
    public function store(StoreDeviceTokenRequest $request): JsonResponse
    {
        $data = $request->validated();

        DeviceToken::updateOrCreate(
            ['token' => $data['token']],
            ['user_id' => $request->user()->id, 'platform' => $data['platform']],
        );

        return response()->json(['registered' => true], Response::HTTP_CREATED);
    }

    public function destroy(Request $request): Response
    {
        DeviceToken::where('user_id', $request->user()->id)
            ->where('token', $request->query('token'))
            ->delete();

        return response()->noContent();
    }
}
