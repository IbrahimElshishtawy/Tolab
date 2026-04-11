<?php

namespace Tests\Feature;

use App\Core\Enums\GroupMemberRole;
use App\Core\Enums\Semester;
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
use App\Modules\Group\Models\Post;
use App\Modules\Notifications\Models\UserNotification;
use App\Modules\Schedule\Enums\ScheduleEventType;
use App\Modules\Schedule\Models\ScheduleEvent;
use App\Modules\UserManagement\Models\StudentProfile;
use App\Modules\UserManagement\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class StudentModuleTest extends TestCase
{
    use RefreshDatabase;

    public function test_student_sees_only_enrolled_courses(): void
    {
        [$student, $offering, $otherOffering] = $this->createStudentScenario();

        Sanctum::actingAs($student);

        $response = $this->getJson('/api/student/courses');

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonCount(1, 'data.data')
            ->assertJsonPath('data.data.0.id', $offering->id)
            ->assertJsonMissing(['id' => $otherOffering->id]);
    }

    public function test_student_cannot_view_course_when_not_enrolled(): void
    {
        [$student, $offering, $otherOffering] = $this->createStudentScenario();

        Sanctum::actingAs($student);

        $response = $this->getJson("/api/student/courses/{$otherOffering->id}");

        $response->assertForbidden()
            ->assertJsonPath('success', false);
    }

    public function test_student_sees_only_own_grades(): void
    {
        [$student, $offering] = $this->createStudentScenario();
        $otherStudent = User::factory()->create(['role' => UserRole::STUDENT]);

        GradeItem::factory()->create([
            'course_offering_id' => $offering->id,
            'student_user_id' => $student->id,
            'score' => 17,
        ]);

        GradeItem::factory()->create([
            'course_offering_id' => $offering->id,
            'student_user_id' => $otherStudent->id,
            'score' => 4,
        ]);

        Sanctum::actingAs($student);

        $response = $this->getJson("/api/student/courses/{$offering->id}/grades");

        $response->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.student_user_id', $student->id)
            ->assertJsonMissing(['student_user_id' => $otherStudent->id]);
    }

    public function test_student_cannot_access_another_students_grade_route_without_enrollment(): void
    {
        [$student, , $otherOffering] = $this->createStudentScenario();

        Sanctum::actingAs($student);

        $response = $this->getJson("/api/student/courses/{$otherOffering->id}/grades");

        $response->assertForbidden()
            ->assertJsonPath('success', false);
    }

    public function test_student_can_open_course_group(): void
    {
        [$student, $offering] = $this->createStudentScenario();

        Sanctum::actingAs($student);

        $response = $this->getJson("/api/student/courses/{$offering->id}/group");

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.course_offering_id', $offering->id);
    }

    public function test_student_cannot_write_in_group_outside_enrolled_course(): void
    {
        [$student, , $otherOffering] = $this->createStudentScenario();
        $forbiddenGroup = $otherOffering->group;

        Sanctum::actingAs($student);

        $response = $this->postJson("/api/groups/{$forbiddenGroup->id}/posts", [
            'content' => 'Should not pass',
        ]);

        $response->assertForbidden()
            ->assertJsonPath('success', false);
    }

    public function test_student_can_create_post_comment_and_message(): void
    {
        [$student, $offering] = $this->createStudentScenario();
        $group = $offering->group;

        Sanctum::actingAs($student);

        $postResponse = $this->postJson("/api/groups/{$group->id}/posts", [
            'content' => 'Hello group',
        ]);

        $postResponse->assertCreated()
            ->assertJsonPath('data.content_text', 'Hello group');

        $postId = $postResponse->json('data.id');

        $commentResponse = $this->postJson("/api/posts/{$postId}/comments", [
            'text' => 'First comment',
        ]);

        $commentResponse->assertCreated()
            ->assertJsonPath('data.text', 'First comment');

        $messageResponse = $this->postJson("/api/groups/{$group->id}/messages", [
            'text' => 'Direct chat message',
        ]);

        $messageResponse->assertCreated()
            ->assertJsonPath('data.text', 'Direct chat message');
    }

    public function test_student_can_mark_notification_as_read(): void
    {
        [$student] = $this->createStudentScenario();

        $notification = UserNotification::factory()->create([
            'target_user_id' => $student->id,
            'is_read' => false,
        ]);

        Sanctum::actingAs($student);

        $response = $this->patchJson("/api/notifications/{$notification->id}/read");

        $response->assertOk()
            ->assertJsonPath('data.is_read', true);
    }

    public function test_timetable_filters_all_odd_and_even(): void
    {
        [$student, $offering] = $this->createStudentScenario();

        ScheduleEvent::factory()->create([
            'course_offering_id' => $offering->id,
            'type' => ScheduleEventType::LECTURE,
            'week_pattern' => WeekPattern::ALL,
        ]);

        ScheduleEvent::factory()->create([
            'course_offering_id' => $offering->id,
            'type' => ScheduleEventType::SECTION,
            'week_pattern' => WeekPattern::ODD,
        ]);

        ScheduleEvent::factory()->create([
            'course_offering_id' => $offering->id,
            'type' => ScheduleEventType::QUIZ,
            'week_pattern' => WeekPattern::EVEN,
        ]);

        Sanctum::actingAs($student);

        $all = $this->getJson('/api/student/timetable?week=ALL');
        $odd = $this->getJson('/api/student/timetable?week=ODD');
        $even = $this->getJson('/api/student/timetable?week=EVEN');

        $all->assertOk()->assertJsonCount(3, 'data');
        $odd->assertOk()->assertJsonCount(2, 'data');
        $even->assertOk()->assertJsonCount(2, 'data');
    }

    public function test_non_student_cannot_access_student_routes(): void
    {
        [, $offering] = $this->createStudentScenario();
        $doctor = User::factory()->doctor()->create();

        Sanctum::actingAs($doctor);

        $response = $this->getJson("/api/student/courses/{$offering->id}");

        $response->assertForbidden()
            ->assertJsonPath('message', 'Student access required.');
    }

    private function createStudentScenario(): array
    {
        $department = Department::factory()->create();
        $section = Section::factory()->create([
            'department_id' => $department->id,
            'grade_year' => 3,
        ]);

        $subject = Subject::factory()->create([
            'department_id' => $department->id,
            'grade_year' => 3,
            'semester' => Semester::FIRST,
        ]);

        $otherSubject = Subject::factory()->create([
            'department_id' => $department->id,
            'grade_year' => 3,
            'semester' => Semester::FIRST,
        ]);

        $doctor = User::factory()->doctor()->create();
        $ta = User::factory()->teachingAssistant()->create();

        $offering = CourseOffering::factory()->create([
            'subject_id' => $subject->id,
            'section_id' => $section->id,
            'doctor_user_id' => $doctor->id,
            'ta_user_id' => $ta->id,
            'semester' => Semester::FIRST,
        ]);

        $otherOffering = CourseOffering::factory()->create([
            'subject_id' => $otherSubject->id,
            'section_id' => $section->id,
            'doctor_user_id' => $doctor->id,
            'ta_user_id' => $ta->id,
            'semester' => Semester::FIRST,
        ]);

        $group = GroupChat::factory()->create([
            'course_offering_id' => $offering->id,
            'created_by' => $doctor->id,
        ]);

        $otherGroup = GroupChat::factory()->create([
            'course_offering_id' => $otherOffering->id,
            'created_by' => $doctor->id,
        ]);

        $offering->update(['group_id' => $group->id]);
        $otherOffering->update(['group_id' => $otherGroup->id]);

        $student = User::factory()->create([
            'role' => UserRole::STUDENT,
        ]);

        StudentProfile::factory()->create([
            'user_id' => $student->id,
            'department_id' => $department->id,
            'section_id' => $section->id,
            'grade_year' => 3,
        ]);

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

        return [$student, $offering->fresh('group'), $otherOffering->fresh('group')];
    }
}
