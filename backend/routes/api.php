<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BookmarkController;
use App\Http\Controllers\Api\ClaimReviewController;
use App\Http\Controllers\Api\ConversationController;
use App\Http\Controllers\Api\DeviceTokenController;
use App\Http\Controllers\Api\ListingClaimController;
use App\Http\Controllers\Api\ListingController;
use App\Http\Controllers\Api\ListingMatchController;
use App\Http\Controllers\Api\ListingPhotoController;
use App\Http\Controllers\Api\ListingSearchController;
use App\Http\Controllers\Api\MessageController;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);

    Route::get('/listings', [ListingController::class, 'index']);
    Route::post('/listings', [ListingController::class, 'store']);
    Route::get('/listings/search', ListingSearchController::class);
    Route::get('/listings/{listing}', [ListingController::class, 'show']);
    Route::put('/listings/{listing}', [ListingController::class, 'update']);
    Route::delete('/listings/{listing}', [ListingController::class, 'destroy']);
    Route::patch('/listings/{listing}/resolve', [ListingController::class, 'resolve']);
    Route::post('/listings/{listing}/photos', [ListingPhotoController::class, 'store']);
    Route::post('/listings/{listing}/claim', [ListingClaimController::class, 'store']);
    Route::post('/listings/{listing}/bookmark', [BookmarkController::class, 'store']);
    Route::delete('/listings/{listing}/bookmark', [BookmarkController::class, 'destroy']);

    Route::get('/bookmarks', [BookmarkController::class, 'index']);

    Route::post('/device-tokens', [DeviceTokenController::class, 'store']);
    Route::delete('/device-tokens', [DeviceTokenController::class, 'destroy']);

    Route::get('/matches', [ListingMatchController::class, 'index']);
    Route::patch('/matches/{match}', [ListingMatchController::class, 'update']);

    Route::get('/claims', [ClaimReviewController::class, 'index']);
    Route::patch('/claims/{claim}', [ClaimReviewController::class, 'update']);

    Route::get('/conversations', [ConversationController::class, 'index']);
    Route::get('/conversations/{conversation}/messages', [MessageController::class, 'index']);
    Route::post('/conversations/{conversation}/messages', [MessageController::class, 'store']);
});
