<?php

namespace Tests\Feature;

use App\Core\Enums\Semester;
use App\Core\Enums\UserRole;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Academic\Models\Department;
use App\Modules\Academic\Models\Section;
use App\Modules\Academic\Models\Subject;
use App\Modules\Enrollment\Models\Enrollment;
use App\Modules\Group\Models\GroupChat;
use App\Modules\UserManagement\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class EnrollmentAccessTest extends TestCase
{
    use RefreshDatabase;

    public function test_enrolled_student_can_view_course_content_but_other_student_cannot(): void
    {
        $department = Department::factory()->create();
        $section = Section::factory()->create(['department_id' => $department->id]);
        $subject = Subject::factory()->create(['department_id' => $department->id, 'semester' => Semester::FIRST]);
        $offering = CourseOffering::factory()->create([
            'subject_id' => $subject->id,
            'section_id' => $section->id,
            'semester' => Semester::FIRST,
        ]);

        $group = GroupChat::factory()->create(['course_offering_id' => $offering->id]);
        $offering->update(['group_id' => $group->id]);

        $enrolledStudent = User::factory()->create(['role' => UserRole::STUDENT]);
        $otherStudent = User::factory()->create(['role' => UserRole::STUDENT]);

        Enrollment::query()->create([
            'student_user_id' => $enrolledStudent->id,
            'course_offering_id' => $offering->id,
            'status' => Enrollment::STATUS_ENROLLED,
        ]);

        Sanctum::actingAs($enrolledStudent);
        $allowed = $this->getJson("/api/student/courses/{$offering->id}/content");
        $allowed->assertOk()->assertJsonPath('success', true);

        Sanctum::actingAs($otherStudent);
        $forbidden = $this->getJson("/api/student/courses/{$offering->id}/content");
        $forbidden->assertForbidden()->assertJsonPath('success', false);
    }
}
