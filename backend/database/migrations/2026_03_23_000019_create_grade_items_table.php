<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('grade_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('course_offering_id')->constrained()->cascadeOnDelete();
            $table->foreignId('student_user_id')->constrained('users')->cascadeOnDelete();
            $table->string('type', 20);
            $table->decimal('score', 8, 2);
            $table->decimal('max_score', 8, 2);
            $table->text('note')->nullable();
            $table->foreignId('updated_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();

            $table->index(['course_offering_id', 'student_user_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('grade_items');
    }
};
