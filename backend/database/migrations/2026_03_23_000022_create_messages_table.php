<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('group_id')->constrained('group_chats')->cascadeOnDelete();
            $table->foreignId('sender_user_id')->constrained('users')->cascadeOnDelete();
            $table->text('text');
            $table->timestamps();
            $table->softDeletes();

            $table->index(['group_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('messages');
    }
};
