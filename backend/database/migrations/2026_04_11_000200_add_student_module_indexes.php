<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('enrollments', function (Blueprint $table) {
            $table->index(['student_user_id', 'status', 'course_offering_id'], 'enrollments_student_status_course_idx');
        });

        Schema::table('schedule_events', function (Blueprint $table) {
            $table->index(['course_offering_id', 'week_pattern', 'day_of_week', 'start_time'], 'schedule_events_student_lookup_idx');
        });

        Schema::table('user_notifications', function (Blueprint $table) {
            $table->index(['target_user_id', 'created_at'], 'user_notifications_target_created_idx');
        });
    }

    public function down(): void
    {
        Schema::table('enrollments', function (Blueprint $table) {
            $table->dropIndex('enrollments_student_status_course_idx');
        });

        Schema::table('schedule_events', function (Blueprint $table) {
            $table->dropIndex('schedule_events_student_lookup_idx');
        });

        Schema::table('user_notifications', function (Blueprint $table) {
            $table->dropIndex('user_notifications_target_created_idx');
        });
    }
};
