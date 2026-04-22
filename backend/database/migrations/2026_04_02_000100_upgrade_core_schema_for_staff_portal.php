<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (! Schema::hasColumn('users', 'full_name')) {
                $table->string('full_name', 180)->nullable()->after('username');
            }
            if (! Schema::hasColumn('users', 'university_email')) {
                $table->string('university_email', 180)->nullable()->after('email');
                $table->unique('university_email');
            }
            if (! Schema::hasColumn('users', 'role_type')) {
                $table->string('role_type', 30)->default('assistant')->after('role');
            }
            if (! Schema::hasColumn('users', 'avatar')) {
                $table->string('avatar', 255)->nullable()->after('is_active');
            }
            if (! Schema::hasColumn('users', 'phone')) {
                $table->string('phone', 40)->nullable()->after('avatar');
            }
            if (! Schema::hasColumn('users', 'last_login_at')) {
                $table->timestamp('last_login_at')->nullable()->after('phone');
            }
            if (! Schema::hasColumn('users', 'notification_enabled')) {
                $table->boolean('notification_enabled')->default(true)->after('last_login_at');
            }
            if (! Schema::hasColumn('users', 'language')) {
                $table->string('language', 10)->default('en')->after('notification_enabled');
            }
        });

        Schema::table('departments', function (Blueprint $table) {
            if (! Schema::hasColumn('departments', 'code')) {
                $table->string('code', 40)->nullable()->after('name');
                $table->unique('code');
            }
            if (! Schema::hasColumn('departments', 'description')) {
                $table->text('description')->nullable()->after('code');
            }
            if (! Schema::hasColumn('departments', 'is_active')) {
                $table->boolean('is_active')->default(true)->after('description');
            }
        });

        Schema::table('subjects', function (Blueprint $table) {
            if (! Schema::hasColumn('subjects', 'description')) {
                $table->text('description')->nullable()->after('code');
            }
        });

        Schema::table('sections', function (Blueprint $table) {
            if (! Schema::hasColumn('sections', 'code')) {
                $table->string('code', 40)->nullable()->after('name');
            }
            if (! Schema::hasColumn('sections', 'subject_id')) {
                $table->foreignId('subject_id')->nullable()->after('code')->constrained('subjects')->nullOnDelete();
            }
            if (! Schema::hasColumn('sections', 'academic_year_id')) {
                $table->unsignedBigInteger('academic_year_id')->nullable()->after('department_id');
            }
            if (! Schema::hasColumn('sections', 'assistant_id')) {
                $table->foreignId('assistant_id')->nullable()->after('academic_year_id')->constrained('users')->nullOnDelete();
            }
            if (! Schema::hasColumn('sections', 'is_active')) {
                $table->boolean('is_active')->default(true)->after('assistant_id');
            }
        });

        Schema::table('lectures', function (Blueprint $table) {
            if (! Schema::hasColumn('lectures', 'subject_id')) {
                $table->foreignId('subject_id')->nullable()->after('course_offering_id')->constrained('subjects')->nullOnDelete();
            }
            if (! Schema::hasColumn('lectures', 'created_by')) {
                $table->foreignId('created_by')->nullable()->after('subject_id')->constrained('users')->nullOnDelete();
            }
            if (! Schema::hasColumn('lectures', 'week_number')) {
                $table->unsignedTinyInteger('week_number')->default(1)->after('created_by');
            }
            if (! Schema::hasColumn('lectures', 'instructor_name')) {
                $table->string('instructor_name', 180)->nullable()->after('title');
            }
            if (! Schema::hasColumn('lectures', 'video_url')) {
                $table->string('video_url', 255)->nullable()->after('instructor_name');
            }
            if (! Schema::hasColumn('lectures', 'file_path')) {
                $table->string('file_path', 255)->nullable()->after('video_url');
            }
            if (! Schema::hasColumn('lectures', 'is_published')) {
                $table->boolean('is_published')->default(false)->after('file_path');
            }
            if (! Schema::hasColumn('lectures', 'published_at')) {
                $table->timestamp('published_at')->nullable()->after('is_published');
            }
        });

        Schema::table('schedule_events', function (Blueprint $table) {
            if (! Schema::hasColumn('schedule_events', 'subject_id')) {
                $table->foreignId('subject_id')->nullable()->after('course_offering_id')->constrained('subjects')->nullOnDelete();
            }
            if (! Schema::hasColumn('schedule_events', 'department_id')) {
                $table->foreignId('department_id')->nullable()->after('subject_id')->constrained('departments')->nullOnDelete();
            }
            if (! Schema::hasColumn('schedule_events', 'academic_year_id')) {
                $table->unsignedBigInteger('academic_year_id')->nullable()->after('department_id');
            }
            if (! Schema::hasColumn('schedule_events', 'staff_user_id')) {
                $table->foreignId('staff_user_id')->nullable()->after('academic_year_id')->constrained('users')->nullOnDelete();
            }
            if (! Schema::hasColumn('schedule_events', 'event_type')) {
                $table->string('event_type', 30)->nullable()->after('staff_user_id');
            }
            if (! Schema::hasColumn('schedule_events', 'title')) {
                $table->string('title', 180)->nullable()->after('event_type');
            }
            if (! Schema::hasColumn('schedule_events', 'description')) {
                $table->text('description')->nullable()->after('title');
            }
            if (! Schema::hasColumn('schedule_events', 'event_date')) {
                $table->date('event_date')->nullable()->after('description');
            }
            if (! Schema::hasColumn('schedule_events', 'color_key')) {
                $table->string('color_key', 60)->nullable()->after('location');
            }
            if (! Schema::hasColumn('schedule_events', 'is_completed')) {
                $table->boolean('is_completed')->default(false)->after('color_key');
            }
        });

        Schema::table('user_notifications', function (Blueprint $table) {
            if (! Schema::hasColumn('user_notifications', 'category')) {
                $table->string('category', 80)->nullable()->after('body');
            }
            if (! Schema::hasColumn('user_notifications', 'target_type')) {
                $table->string('target_type', 80)->nullable()->after('category');
            }
            if (! Schema::hasColumn('user_notifications', 'target_id')) {
                $table->unsignedBigInteger('target_id')->nullable()->after('target_type');
            }
            if (! Schema::hasColumn('user_notifications', 'is_global')) {
                $table->boolean('is_global')->default(false)->after('target_id');
            }
            if (! Schema::hasColumn('user_notifications', 'created_by')) {
                $table->foreignId('created_by')->nullable()->after('is_global')->constrained('users')->nullOnDelete();
            }
        });

        Schema::table('posts', function (Blueprint $table) {
            if (! Schema::hasColumn('posts', 'is_active')) {
                $table->boolean('is_active')->default(true)->after('content_text');
            }
        });

        Schema::table('comments', function (Blueprint $table) {
            if (! Schema::hasColumn('comments', 'is_active')) {
                $table->boolean('is_active')->default(true)->after('text');
            }
        });
    }

    public function down(): void {}
};
