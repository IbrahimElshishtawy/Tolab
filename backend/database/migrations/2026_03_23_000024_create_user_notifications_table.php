<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_notifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('target_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('title', 180);
            $table->text('body');
            $table->string('type', 30);
            $table->string('ref_type', 80)->nullable();
            $table->unsignedBigInteger('ref_id')->nullable();
            $table->boolean('is_read')->default(false);
            $table->timestamps();

            $table->index(['target_user_id', 'is_read']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_notifications');
    }
};
