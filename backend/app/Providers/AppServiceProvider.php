<?php

namespace App\Providers;

use App\Models\Conversation;
use App\Models\Listing;
use App\Models\ListingMatch;
use App\Policies\ConversationPolicy;
use App\Policies\ListingMatchPolicy;
use App\Policies\ListingPolicy;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Gate::policy(Listing::class, ListingPolicy::class);
        Gate::policy(ListingMatch::class, ListingMatchPolicy::class);
        Gate::policy(Conversation::class, ConversationPolicy::class);
    }
}
