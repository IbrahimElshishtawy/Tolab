<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('enrollments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('student_user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('course_offering_id')->constrained()->cascadeOnDelete();
            $table->timestamps();

            $table->unique(['student_user_id', 'course_offering_id'], 'enrollment_unique');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('enrollments');
    }
};
