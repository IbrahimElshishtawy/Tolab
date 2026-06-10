<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('grade_categories', function (Blueprint $table) {
            $table->id();
            $table->foreignId('subject_id')->constrained('subjects')->cascadeOnDelete();
            $table->string('key_name', 50);
            $table->string('label', 100);
            $table->decimal('max_score', 5, 2)->default(100.00);
            $table->string('status', 20)->default('draft'); // 'draft', 'published'
            $table->timestamps();

            $table->unique(['subject_id', 'key_name']);
            $table->index('subject_id');
        });

        Schema::create('student_grades', function (Blueprint $table) {
            $table->id();
            $table->foreignId('student_id')->constrained('student_profiles')->cascadeOnDelete();
            $table->foreignId('grade_category_id')->constrained('grade_categories')->cascadeOnDelete();
            $table->decimal('score', 5, 2)->nullable();
            $table->string('status', 20)->default('draft'); // 'draft', 'published'
            $table->text('note')->nullable();
            $table->foreignId('graded_by')->constrained('users');
            $table->timestamps();

            $table->unique(['student_id', 'grade_category_id']);
            $table->index(['student_id', 'grade_category_id']);
        });

        Schema::create('uploaded_grade_sheets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('subject_id')->constrained('subjects')->cascadeOnDelete();
            $table->foreignId('grade_category_id')->constrained('grade_categories')->cascadeOnDelete();
            $table->string('file_name', 255);
            $table->text('file_url');
            $table->string('mime_type', 100);
            $table->integer('file_size_bytes');
            $table->foreignId('uploaded_by')->constrained('users');
            $table->timestamp('created_at')->nullable();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('uploaded_grade_sheets');
        Schema::dropIfExists('student_grades');
        Schema::dropIfExists('grade_categories');
    }
};
