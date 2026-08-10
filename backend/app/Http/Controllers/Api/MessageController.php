<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Conversation\StoreMessageRequest;
use App\Models\Conversation;
use App\Services\Notifications\FcmService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Gate;

class MessageController extends Controller
{
    public function index(Request $request, Conversation $conversation): JsonResponse
    {
        Gate::authorize('view', $conversation);

        $conversation->messages()
            ->where('sender_id', '!=', $request->user()->id)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);

        $messages = $conversation->messages()
            ->orderBy('created_at')
            ->orderBy('id')
            ->paginate(15);

        return response()->json($messages);
    }

    public function store(StoreMessageRequest $request, Conversation $conversation, FcmService $fcmService): JsonResponse
    {
        Gate::authorize('view', $conversation);

        $message = $conversation->messages()->create([
            'sender_id' => $request->user()->id,
            'content' => $request->validated()['content'],
        ]);

        $conversation->loadMissing(['userOne', 'userTwo']);
        $recipient = $message->sender_id === $conversation->user_one_id ? $conversation->userTwo : $conversation->userOne;

        $fcmService->sendToUser($recipient, 'Nouveau message', $message->content, [
            'type' => 'message',
            'conversation_id' => (string) $conversation->id,
        ]);

        return response()->json($message, Response::HTTP_CREATED);
    }
}
