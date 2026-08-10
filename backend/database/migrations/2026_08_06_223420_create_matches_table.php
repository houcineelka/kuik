<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('matches', function (Blueprint $table) {
            $table->id();
            $table->foreignId('lost_listing_id')->constrained('listings')->cascadeOnDelete();
            $table->foreignId('found_listing_id')->constrained('listings')->cascadeOnDelete();
            $table->float('score');
            $table->enum('status', ['suggested', 'confirmed', 'rejected'])->default('suggested');
            $table->timestamp('created_at')->nullable();

            $table->unique(['lost_listing_id', 'found_listing_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('matches');
    }
};
