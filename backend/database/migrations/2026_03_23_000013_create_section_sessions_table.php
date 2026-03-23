<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('section_sessions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('course_offering_id')->constrained()->cascadeOnDelete();
            $table->string('title', 180);
            $table->date('date')->nullable();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('section_sessions');
    }
};
