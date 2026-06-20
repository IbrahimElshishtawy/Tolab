<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        $isSqlite = DB::connection($this->getConnection())->getDriverName() === 'sqlite';

        // 1. Drop old indexes and foreign key constraints on course_offering_id
        Schema::table('staff_assignments', function (Blueprint $table) use ($isSqlite) {
            if (!$isSqlite) {
                $table->dropForeign(['user_id']);
                $table->dropForeign(['course_offering_id']);
            }
        });
        Schema::table('staff_assignments', function (Blueprint $table) {
            $table->dropIndex('staff_assignments_user_course_offering_idx');
        });

        Schema::table('academic_section_contents', function (Blueprint $table) use ($isSqlite) {
            if (!$isSqlite) {
                $table->dropForeign(['course_offering_id']);
            }
        });
        Schema::table('academic_section_contents', function (Blueprint $table) {
            $table->dropIndex('section_contents_subject_publish_idx');
        });

        Schema::table('quizzes', function (Blueprint $table) use ($isSqlite) {
            if (!$isSqlite) {
                $table->dropForeign(['course_offering_id']);
            }
        });
        Schema::table('quizzes', function (Blueprint $table) {
            $table->dropIndex('quizzes_subject_date_publish_idx');
        });

        Schema::table('tasks', function (Blueprint $table) use ($isSqlite) {
            if (!$isSqlite) {
                $table->dropForeign(['course_offering_id']);
            }
        });
        Schema::table('tasks', function (Blueprint $table) {
            $table->dropIndex('tasks_subject_due_publish_idx');
        });

        // 2. Rename course_offering_id to subject_id in staff_assignments, academic_section_contents, quizzes, and tasks
        Schema::table('staff_assignments', function (Blueprint $table) {
            $table->renameColumn('course_offering_id', 'subject_id');
        });

        Schema::table('academic_section_contents', function (Blueprint $table) {
            $table->renameColumn('course_offering_id', 'subject_id');
        });

        Schema::table('quizzes', function (Blueprint $table) {
            $table->renameColumn('course_offering_id', 'subject_id');
        });

        Schema::table('tasks', function (Blueprint $table) {
            $table->renameColumn('course_offering_id', 'subject_id');
            $table->renameColumn('due_at', 'due_date');
        });

        // 3. Recreate foreign keys and indexes
        Schema::table('staff_assignments', function (Blueprint $table) use ($isSqlite) {
            if (!$isSqlite) {
                $table->foreign('user_id')->references('id')->on('users')->cascadeOnDelete();
                $table->foreign('subject_id')->references('id')->on('subjects')->cascadeOnDelete();
            } else {
                $table->foreign('subject_id')->references('id')->on('subjects')->cascadeOnDelete();
            }
            $table->index(['user_id', 'subject_id'], 'staff_assignments_user_subject_idx');
        });

        Schema::table('academic_section_contents', function (Blueprint $table) {
            $table->foreign('subject_id')->references('id')->on('subjects')->cascadeOnDelete();
            $table->index(['subject_id', 'is_published', 'published_at'], 'section_contents_subject_publish_idx');
        });

        Schema::table('quizzes', function (Blueprint $table) {
            $table->foreign('subject_id')->references('id')->on('subjects')->cascadeOnDelete();
            $table->index(['subject_id', 'quiz_date', 'is_published'], 'quizzes_subject_date_publish_idx');
        });

        Schema::table('tasks', function (Blueprint $table) {
            $table->foreign('subject_id')->references('id')->on('subjects')->cascadeOnDelete();
            $table->index(['subject_id', 'due_date', 'is_published'], 'tasks_subject_due_publish_idx');
        });

        // 4. Add index on uploaded_grade_sheets(subject_id)
        Schema::table('uploaded_grade_sheets', function (Blueprint $table) {
            $table->index('subject_id');
        });

        // 5. Add composite index on enrollments(course_offering_id, status)
        Schema::table('enrollments', function (Blueprint $table) {
            $table->index(['course_offering_id', 'status']);
        });

        // 6. Drop redundant index student_grades_student_id_grade_category_id_index
        Schema::table('student_grades', function (Blueprint $table) {
            $table->dropIndex(['student_id', 'grade_category_id']);
        });

        // 7. Drop grade_items table
        Schema::dropIfExists('grade_items');
    }

    public function down(): void
    {
    }
};
