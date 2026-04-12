<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('staff_assignments', function (Blueprint $table) {
            $table->index(['user_id', 'subject_id'], 'staff_assignments_user_subject_idx');
        });

        Schema::table('lectures', function (Blueprint $table) {
            $table->index(['subject_id', 'is_published', 'published_at'], 'lectures_subject_publish_idx');
        });

        Schema::table('academic_section_contents', function (Blueprint $table) {
            $table->index(['subject_id', 'is_published', 'published_at'], 'section_contents_subject_publish_idx');
        });

        Schema::table('quizzes', function (Blueprint $table) {
            $table->index(['subject_id', 'quiz_date', 'is_published'], 'quizzes_subject_date_publish_idx');
        });

        Schema::table('tasks', function (Blueprint $table) {
            $table->index(['subject_id', 'due_date', 'is_published'], 'tasks_subject_due_publish_idx');
        });

        Schema::table('schedule_events', function (Blueprint $table) {
            $table->index(['staff_user_id', 'event_date', 'start_time'], 'schedule_events_staff_date_idx');
            $table->index(['subject_id', 'event_type', 'event_date'], 'schedule_events_subject_type_date_idx');
        });

        Schema::table('user_notifications', function (Blueprint $table) {
            $table->index(['target_user_id', 'is_read', 'created_at'], 'notifications_target_read_date_idx');
        });

        Schema::table('comments', function (Blueprint $table) {
            $table->index(['post_id', 'created_at'], 'comments_post_created_idx');
        });
    }

    public function down(): void
    {
        Schema::table('comments', function (Blueprint $table) {
            $table->dropIndex('comments_post_created_idx');
        });

        Schema::table('user_notifications', function (Blueprint $table) {
            $table->dropIndex('notifications_target_read_date_idx');
        });

        Schema::table('schedule_events', function (Blueprint $table) {
            $table->dropIndex('schedule_events_staff_date_idx');
            $table->dropIndex('schedule_events_subject_type_date_idx');
        });

        Schema::table('tasks', function (Blueprint $table) {
            $table->dropIndex('tasks_subject_due_publish_idx');
        });

        Schema::table('quizzes', function (Blueprint $table) {
            $table->dropIndex('quizzes_subject_date_publish_idx');
        });

        Schema::table('academic_section_contents', function (Blueprint $table) {
            $table->dropIndex('section_contents_subject_publish_idx');
        });

        Schema::table('lectures', function (Blueprint $table) {
            $table->dropIndex('lectures_subject_publish_idx');
        });

        Schema::table('staff_assignments', function (Blueprint $table) {
            $table->dropIndex('staff_assignments_user_subject_idx');
        });
    }
};
