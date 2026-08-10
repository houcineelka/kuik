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
        Schema::table('users', function (Blueprint $table) {
            $table->string('phone')->unique()->after('name');
            $table->string('city')->after('phone');
            $table->string('avatar_url')->nullable()->after('city');
            $table->unsignedInteger('reputation_score')->default(0)->after('avatar_url');
            $table->string('email')->nullable()->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['phone', 'city', 'avatar_url', 'reputation_score']);
            $table->string('email')->nullable(false)->change();
        });
    }
};
