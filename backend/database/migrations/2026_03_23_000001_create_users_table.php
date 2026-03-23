<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('role', 20);
            $table->string('username', 120);
            $table->string('email')->unique();
            $table->string('password_hash');
            $table->string('national_id', 40)->nullable()->unique();
            $table->boolean('is_active')->default(true);
            $table->rememberToken();
            $table->timestamps();

            $table->index(['role', 'is_active']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
