<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('academic_years', function (Blueprint $table) {
            $table->id();
            $table->string('name', 120);
            $table->unsignedTinyInteger('level');
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::table('subjects', function (Blueprint $table) {
            if (! Schema::hasColumn('subjects', 'academic_year_id')) {
                $table->foreignId('academic_year_id')->nullable()->after('department_id')->constrained('academic_years')->nullOnDelete();
            }
        });

        Schema::table('sections', function (Blueprint $table) {
            if (Schema::hasColumn('sections', 'academic_year_id')) {
                $table->foreign('academic_year_id')->references('id')->on('academic_years')->nullOnDelete();
            }
        });

        Schema::table('schedule_events', function (Blueprint $table) {
            if (Schema::hasColumn('schedule_events', 'academic_year_id')) {
                $table->foreign('academic_year_id')->references('id')->on('academic_years')->nullOnDelete();
            }
        });

        Schema::create('portal_roles', function (Blueprint $table) {
            $table->id();
            $table->string('name', 80)->unique();
            $table->string('label', 120);
            $table->timestamps();
        });

        Schema::create('portal_permissions', function (Blueprint $table) {
            $table->id();
            $table->string('name', 120)->unique();
            $table->string('group_name', 80);
            $table->string('label', 180);
            $table->timestamps();
        });

        Schema::create('portal_permission_role', function (Blueprint $table) {
            $table->foreignId('role_id')->constrained('portal_roles')->cascadeOnDelete();
            $table->foreignId('permission_id')->constrained('portal_permissions')->cascadeOnDelete();
            $table->primary(['role_id', 'permission_id']);
        });

        Schema::create('portal_role_user', function (Blueprint $table) {
            $table->foreignId('role_id')->constrained('portal_roles')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->primary(['role_id', 'user_id']);
        });

        Schema::create('portal_permission_user', function (Blueprint $table) {
            $table->foreignId('permission_id')->constrained('portal_permissions')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->primary(['permission_id', 'user_id']);
        });

        Schema::create('staff_assignments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('subject_id')->constrained('subjects')->cascadeOnDelete();
            $table->foreignId('section_id')->nullable()->constrained('sections')->nullOnDelete();
            $table->foreignId('department_id')->constrained('departments')->cascadeOnDelete();
            $table->foreignId('academic_year_id')->nullable()->constrained('academic_years')->nullOnDelete();
            $table->string('assignment_type', 30);
            $table->timestamps();
        });

        Schema::create('academic_section_contents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('subject_id')->constrained('subjects')->cascadeOnDelete();
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->unsignedTinyInteger('week_number')->default(1);
            $table->string('title', 180);
            $table->string('assistant_name', 180)->nullable();
            $table->string('video_url', 255)->nullable();
            $table->string('file_path', 255)->nullable();
            $table->boolean('is_published')->default(false);
            $table->timestamp('published_at')->nullable();
            $table->timestamps();
        });

        Schema::create('quizzes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('subject_id')->constrained('subjects')->cascadeOnDelete();
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->unsignedTinyInteger('week_number')->default(1);
            $table->string('title', 180);
            $table->string('owner_name', 180)->nullable();
            $table->string('quiz_type', 20)->default('offline');
            $table->string('quiz_link', 255)->nullable();
            $table->date('quiz_date')->nullable();
            $table->boolean('is_published')->default(false);
            $table->timestamps();
        });

        Schema::create('tasks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('subject_id')->constrained('subjects')->cascadeOnDelete();
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->unsignedTinyInteger('week_number')->default(1);
            $table->string('title', 180);
            $table->string('lecture_or_section_name', 180)->nullable();
            $table->string('owner_name', 180)->nullable();
            $table->string('file_path', 255)->nullable();
            $table->date('due_date')->nullable();
            $table->boolean('is_published')->default(false);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tasks');
        Schema::dropIfExists('quizzes');
        Schema::dropIfExists('academic_section_contents');
        Schema::dropIfExists('staff_assignments');
        Schema::dropIfExists('portal_permission_user');
        Schema::dropIfExists('portal_role_user');
        Schema::dropIfExists('portal_permission_role');
        Schema::dropIfExists('portal_permissions');
        Schema::dropIfExists('portal_roles');
        Schema::dropIfExists('academic_years');
    }
};
