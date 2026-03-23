<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('group_chats', function (Blueprint $table) {
            $table->id();
            $table->foreignId('course_offering_id')->unique()->constrained()->cascadeOnDelete();
            $table->string('name', 180);
            $table->text('description')->nullable();
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
        });

        Schema::table('course_offerings', function (Blueprint $table) {
            $table->foreign('group_id')->references('id')->on('group_chats')->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('course_offerings', function (Blueprint $table) {
            $table->dropForeign(['group_id']);
        });

        Schema::dropIfExists('group_chats');
    }
};
