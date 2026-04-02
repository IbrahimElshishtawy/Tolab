<?php

namespace Database\Seeders;

use App\Core\Enums\Semester;
use App\Core\Enums\StaffTitle;
use App\Core\Enums\UserRole;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Academic\Models\Department;
use App\Modules\Academic\Models\Section;
use App\Modules\Academic\Models\Subject;
use App\Modules\Group\Models\GroupChat;
use App\Modules\Group\Models\GroupMember;
use App\Modules\UserManagement\Models\StaffPermission;
use App\Modules\UserManagement\Models\StaffProfile;
use App\Modules\UserManagement\Models\StudentProfile;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call(SuperAdminSeeder::class);
        $sharedPassword = (string) env('DEFAULT_ACADEMY_PASSWORD', env('DEFAULT_ADMIN_PASSWORD', 'Admin@123'));

        DB::transaction(function () use ($sharedPassword) {
            $department = Department::factory()->create(['name' => 'Computer Science']);
            $section = Section::factory()->create([
                'department_id' => $department->id,
                'name' => 'General',
                'grade_year' => 3,
            ]);

            $doctor = User::factory()->doctor()->create([
                'username' => 'Dr. Ahmed Hassan',
                'full_name' => 'Dr. Ahmed Hassan',
                'email' => 'doctor@tolab.edu',
                'university_email' => 'doctor@tolab.edu',
                'role_type' => 'doctor',
                'password_hash' => Hash::make($sharedPassword),
            ]);

            $ta = User::factory()->teachingAssistant()->create([
                'username' => 'TA Sara Ali',
                'full_name' => 'TA Sara Ali',
                'email' => 'assistant@tolab.edu',
                'university_email' => 'assistant@tolab.edu',
                'role_type' => 'assistant',
            ]);

            $student = User::factory()->create([
                'role' => UserRole::STUDENT,
                'username' => 'Mohamed Ibrahim',
                'full_name' => 'Mohamed Ibrahim',
                'email' => 'student@tolab.edu',
                'university_email' => 'student@tolab.edu',
                'role_type' => 'student',
                'password_hash' => Hash::make($sharedPassword),
                'national_id' => '29801011234567',
            ]);

            StudentProfile::query()->create([
                'user_id' => $student->id,
                'gpa' => 3.21,
                'grade_year' => 3,
                'section_id' => $section->id,
                'department_id' => $department->id,
            ]);

            StaffProfile::query()->create([
                'user_id' => $doctor->id,
                'department_id' => $department->id,
                'title' => StaffTitle::DOCTOR,
            ]);

            StaffProfile::query()->create([
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

            StaffPermission::query()->create([
                'user_id' => $ta->id,
                'can_upload_content' => true,
                'can_manage_grades' => false,
                'can_manage_schedule' => false,
                'can_moderate_group' => true,
            ]);

            $subject = Subject::factory()->create([
                'department_id' => $department->id,
                'name' => 'Database Systems',
                'code' => 'CS303',
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

            $group = GroupChat::query()->create([
                'course_offering_id' => $offering->id,
                'name' => 'Database Systems - General',
                'description' => 'Official course discussion group',
                'created_by' => $doctor->id,
            ]);

            $offering->update(['group_id' => $group->id]);

            GroupMember::query()->insert([
                [
                    'group_id' => $group->id,
                    'user_id' => $doctor->id,
                    'role_in_group' => 'OWNER',
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
                [
                    'group_id' => $group->id,
                    'user_id' => $ta->id,
                    'role_in_group' => 'MOD',
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
                [
                    'group_id' => $group->id,
                    'user_id' => $student->id,
                    'role_in_group' => 'MEMBER',
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
            ]);

            $student->enrollments()->create([
                'course_offering_id' => $offering->id,
            ]);
        });
    }
}
