<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('course_offerings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('subject_id')->constrained()->cascadeOnDelete();
            $table->foreignId('section_id')->constrained()->cascadeOnDelete();
            $table->string('academic_year', 20);
            $table->string('semester', 20);
            $table->foreignId('doctor_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('ta_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->unsignedBigInteger('group_id')->nullable();
            $table->timestamps();

            $table->unique(['subject_id', 'section_id', 'academic_year', 'semester'], 'course_offering_unique');
            $table->index(['section_id', 'semester']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('course_offerings');
    }
};
