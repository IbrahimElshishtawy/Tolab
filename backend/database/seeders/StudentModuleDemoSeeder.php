<?php

namespace Database\Seeders;

use App\Core\Enums\GroupMemberRole;
use App\Core\Enums\Semester;
use App\Core\Enums\StaffTitle;
use App\Core\Enums\UserRole;
use App\Core\Enums\WeekPattern;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Academic\Models\Department;
use App\Modules\Academic\Models\Section;
use App\Modules\Academic\Models\Subject;
use App\Modules\Enrollment\Models\Enrollment;
use App\Modules\Grades\Models\GradeItem;
use App\Modules\Group\Models\GroupChat;
use App\Modules\Group\Models\GroupMember;
use App\Modules\Notifications\Models\UserNotification;
use App\Modules\Schedule\Enums\ScheduleEventType;
use App\Modules\Schedule\Models\ScheduleEvent;
use App\Modules\UserManagement\Models\StaffPermission;
use App\Modules\UserManagement\Models\StaffProfile;
use App\Modules\UserManagement\Models\StudentProfile;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class StudentModuleDemoSeeder extends Seeder
{
    public function run(): void
    {
        DB::transaction(function () {
            $department = Department::factory()->create([
                'name' => 'Computer Science',
                'code' => 'CS',
            ]);

            $section = Section::factory()->create([
                'department_id' => $department->id,
                'name' => 'Section A',
                'grade_year' => 3,
            ]);

            $doctor = User::factory()->doctor()->create([
                'username' => 'dr.backend',
                'full_name' => 'Dr. Backend',
                'email' => 'doctor.student-module@tolab.edu',
                'university_email' => 'doctor.student-module@tolab.edu',
                'password_hash' => Hash::make('Doctor@123'),
            ]);

            $ta = User::factory()->teachingAssistant()->create([
                'username' => 'ta.backend',
                'full_name' => 'TA Backend',
                'email' => 'ta.student-module@tolab.edu',
                'university_email' => 'ta.student-module@tolab.edu',
                'password_hash' => Hash::make('Ta@123456'),
            ]);

            $student = User::factory()->create([
                'role' => UserRole::STUDENT,
                'username' => 'student.backend',
                'full_name' => 'Student Backend',
                'email' => 'student.student-module@tolab.edu',
                'university_email' => 'student.student-module@tolab.edu',
                'national_id' => '29901011234567',
                'password_hash' => Hash::make('29901011234567'),
            ]);

            StudentProfile::factory()->create([
                'user_id' => $student->id,
                'department_id' => $department->id,
                'section_id' => $section->id,
                'grade_year' => 3,
            ]);

            StaffProfile::factory()->create([
                'user_id' => $doctor->id,
                'department_id' => $department->id,
                'title' => StaffTitle::DOCTOR,
            ]);

            StaffProfile::factory()->create([
                'user_id' => $ta->id,
                'department_id' => $department->id,
                'title' => StaffTitle::TA,
            ]);

            StaffPermission::query()->create([
                'user_id' => $doctor->id,
                'can_upload_content' => true,
                'can_manage_grades' => true,
                'can_manage_schedule' => true,
                'can_moderate_group' => true,
            ]);

            $subject = Subject::factory()->create([
                'department_id' => $department->id,
                'name' => 'Advanced Databases',
                'code' => 'CS401',
                'grade_year' => 3,
                'semester' => Semester::SECOND,
            ]);

            $offering = CourseOffering::factory()->create([
                'subject_id' => $subject->id,
                'section_id' => $section->id,
                'doctor_user_id' => $doctor->id,
                'ta_user_id' => $ta->id,
                'academic_year' => '2025/2026',
                'semester' => Semester::SECOND,
            ]);

            $group = GroupChat::factory()->create([
                'course_offering_id' => $offering->id,
                'created_by' => $doctor->id,
                'name' => 'Advanced Databases Group',
            ]);

            $offering->update(['group_id' => $group->id]);

            Enrollment::factory()->create([
                'student_user_id' => $student->id,
                'course_offering_id' => $offering->id,
                'status' => Enrollment::STATUS_ENROLLED,
            ]);

            GroupMember::query()->insert([
                [
                    'group_id' => $group->id,
                    'user_id' => $doctor->id,
                    'role_in_group' => GroupMemberRole::OWNER->value,
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
                [
                    'group_id' => $group->id,
                    'user_id' => $ta->id,
                    'role_in_group' => GroupMemberRole::MOD->value,
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
                [
                    'group_id' => $group->id,
                    'user_id' => $student->id,
                    'role_in_group' => GroupMemberRole::MEMBER->value,
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
            ]);

            ScheduleEvent::factory()->create([
                'course_offering_id' => $offering->id,
                'type' => ScheduleEventType::LECTURE,
                'week_pattern' => WeekPattern::ALL,
            ]);

            GradeItem::factory()->create([
                'course_offering_id' => $offering->id,
                'student_user_id' => $student->id,
                'updated_by' => $doctor->id,
            ]);

            UserNotification::factory()->create([
                'target_user_id' => $student->id,
                'title' => 'New grade published',
                'body' => 'Your midterm grade is now available.',
            ]);
        });
    }
}
