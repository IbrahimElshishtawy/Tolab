<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('quizzes', function (Blueprint $table) {
            if (! Schema::hasColumn('quizzes', 'description')) {
                $table->text('description')->nullable()->after('title');
            }
            if (! Schema::hasColumn('quizzes', 'opens_at')) {
                $table->timestamp('opens_at')->nullable()->after('quiz_date');
            }
            if (! Schema::hasColumn('quizzes', 'closes_at')) {
                $table->timestamp('closes_at')->nullable()->after('opens_at');
            }
            if (! Schema::hasColumn('quizzes', 'duration_minutes')) {
                $table->unsignedSmallInteger('duration_minutes')->nullable()->after('closes_at');
            }
            if (! Schema::hasColumn('quizzes', 'status')) {
                $table->string('status', 20)->default('draft')->after('duration_minutes');
            }
            if (! Schema::hasColumn('quizzes', 'is_graded')) {
                $table->boolean('is_graded')->default(true)->after('status');
            }
            if (! Schema::hasColumn('quizzes', 'is_practice')) {
                $table->boolean('is_practice')->default(false)->after('is_graded');
            }
            if (! Schema::hasColumn('quizzes', 'total_marks')) {
                $table->unsignedInteger('total_marks')->default(0)->after('is_practice');
            }
            if (! Schema::hasColumn('quizzes', 'questions_json')) {
                $table->json('questions_json')->nullable()->after('total_marks');
            }
        });

        Schema::table('lectures', function (Blueprint $table) {
            if (! Schema::hasColumn('lectures', 'meeting_url')) {
                $table->string('meeting_url', 255)->nullable()->after('video_url');
            }
            if (! Schema::hasColumn('lectures', 'delivery_mode')) {
                $table->string('delivery_mode', 20)->default('online')->after('meeting_url');
            }
            if (! Schema::hasColumn('lectures', 'starts_at')) {
                $table->timestamp('starts_at')->nullable()->after('delivery_mode');
            }
            if (! Schema::hasColumn('lectures', 'ends_at')) {
                $table->timestamp('ends_at')->nullable()->after('starts_at');
            }
            if (! Schema::hasColumn('lectures', 'location_label')) {
                $table->string('location_label', 180)->nullable()->after('ends_at');
            }
            if (! Schema::hasColumn('lectures', 'attachment_label')) {
                $table->string('attachment_label', 180)->nullable()->after('location_label');
            }
        });

        Schema::table('academic_section_contents', function (Blueprint $table) {
            if (! Schema::hasColumn('academic_section_contents', 'description')) {
                $table->text('description')->nullable()->after('title');
            }
            if (! Schema::hasColumn('academic_section_contents', 'meeting_url')) {
                $table->string('meeting_url', 255)->nullable()->after('video_url');
            }
            if (! Schema::hasColumn('academic_section_contents', 'delivery_mode')) {
                $table->string('delivery_mode', 20)->default('online')->after('meeting_url');
            }
            if (! Schema::hasColumn('academic_section_contents', 'starts_at')) {
                $table->timestamp('starts_at')->nullable()->after('delivery_mode');
            }
            if (! Schema::hasColumn('academic_section_contents', 'ends_at')) {
                $table->timestamp('ends_at')->nullable()->after('starts_at');
            }
            if (! Schema::hasColumn('academic_section_contents', 'location_label')) {
                $table->string('location_label', 180)->nullable()->after('ends_at');
            }
            if (! Schema::hasColumn('academic_section_contents', 'attachment_label')) {
                $table->string('attachment_label', 180)->nullable()->after('location_label');
            }
        });

        Schema::table('schedule_events', function (Blueprint $table) {
            if (! Schema::hasColumn('schedule_events', 'linked_label')) {
                $table->string('linked_label', 180)->nullable()->after('color_key');
            }
            if (! Schema::hasColumn('schedule_events', 'target_url')) {
                $table->string('target_url', 255)->nullable()->after('linked_label');
            }
        });

        Schema::table('posts', function (Blueprint $table) {
            if (! Schema::hasColumn('posts', 'title')) {
                $table->string('title', 180)->nullable()->after('author_user_id');
            }
            if (! Schema::hasColumn('posts', 'post_type')) {
                $table->string('post_type', 30)->default('post')->after('content_text');
            }
            if (! Schema::hasColumn('posts', 'priority')) {
                $table->string('priority', 20)->default('normal')->after('post_type');
            }
            if (! Schema::hasColumn('posts', 'visibility')) {
                $table->string('visibility', 40)->default('course_group')->after('priority');
            }
            if (! Schema::hasColumn('posts', 'is_published')) {
                $table->boolean('is_published')->default(true)->after('visibility');
            }
            if (! Schema::hasColumn('posts', 'published_at')) {
                $table->timestamp('published_at')->nullable()->after('is_published');
            }
        });
    }

    public function down(): void {}
};
