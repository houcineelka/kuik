<?php

namespace App\Services\Notifications;

use App\Models\DeviceToken;
use App\Models\User;
use Illuminate\Support\Facades\Log;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Exception\Messaging\InvalidArgument;
use Kreait\Firebase\Exception\Messaging\NotFound;
use Kreait\Firebase\Messaging\CloudMessage;
use Throwable;

/**
 * Sends FCM push notifications. No-ops silently when Firebase credentials
 * aren't configured yet, so listing/messaging flows never break waiting on
 * the Firebase project to be set up.
 */
class FcmService
{
    public function sendToUser(User $user, string $title, string $body, array $data = []): void
    {
        if (blank(config('firebase.projects.app.credentials'))) {
            return;
        }

        $tokens = $user->deviceTokens()->pluck('token');

        if ($tokens->isEmpty()) {
            return;
        }

        $messaging = app(Messaging::class);

        foreach ($tokens as $token) {
            $message = CloudMessage::withTarget('token', $token)
                ->withNotification(['title' => $title, 'body' => $body])
                ->withData($data);

            try {
                $messaging->send($message);
            } catch (NotFound|InvalidArgument) {
                DeviceToken::where('token', $token)->delete();
            } catch (Throwable $e) {
                Log::warning('FCM send failed', ['token' => $token, 'error' => $e->getMessage()]);
            }
        }
    }
}
