<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('listings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->enum('type', ['lost', 'found']);
            $table->string('category');
            $table->text('description');
            $table->string('city');
            $table->string('neighborhood')->nullable();
            $table->date('event_date');
            $table->string('private_detail')->nullable();
            $table->enum('status', ['active', 'resolved', 'expired'])->default('active');
            $table->timestamps();
        });

        // Laravel's schema builder has no MariaDB-verified POINT/SPATIAL support,
        // so the geo column and its index are added via raw SQL. MariaDB requires
        // spatial-indexed columns to be NOT NULL, which matches the spec (location
        // is a required field on every listing).
        DB::statement('ALTER TABLE listings ADD location POINT NOT NULL AFTER description');
        DB::statement('ALTER TABLE listings ADD SPATIAL INDEX listings_location_spatialindex (location)');
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('listings');
    }
};
