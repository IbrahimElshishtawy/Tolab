<?php

namespace Tests\Feature;

use App\Core\Enums\Semester;
use App\Core\Enums\UserRole;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Academic\Models\Department;
use App\Modules\Academic\Models\Section;
use App\Modules\Academic\Models\Subject;
use App\Modules\Enrollment\Models\Enrollment;
use App\Modules\Grades\Enums\GradeType;
use App\Modules\Grades\Models\GradeItem;
use App\Modules\Group\Models\Comment;
use App\Modules\Group\Models\GroupChat;
use App\Modules\Group\Models\Message;
use App\Modules\Group\Models\Post;
use App\Modules\Notifications\Models\UserNotification;
use App\Modules\Schedule\Models\ScheduleEvent;
use App\Modules\StaffPortal\Models\Permission;
use App\Modules\StaffPortal\Models\Quiz;
use App\Modules\StaffPortal\Models\Task;
use App\Modules\StaffPortal\Models\TaskSubmission;
use App\Modules\UserManagement\Models\StaffPermission;
use App\Modules\UserManagement\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class StaffDashboardTest extends TestCase
{
    use RefreshDatabase;

    public function test_staff_dashboard_accepts_bearer_token_from_staff_portal_login(): void
    {
        $doctor = User::factory()->doctor()->create([
            'full_name' => 'Dr. Token Ready',
            'university_email' => 'doctor@tolab.edu',
            'password_hash' => 'Admin@123',
        ]);
        $this->grantPermissions($doctor, ['tasks.view']);

        $login = $this->postJson('/api/staff-portal/auth/login', [
            'university_email' => 'doctor@tolab.edu',
            'password' => 'Admin@123',
            'device_name' => 'phpunit',
        ]);

        $login->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'user',
                    'tokens' => ['access_token', 'refresh_token'],
                ],
            ]);

        $response = $this
            ->withHeader(
                'Authorization',
                'Bearer '.$login->json('data.tokens.access_token'),
            )
            ->getJson('/api/staff/dashboard');

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.header.user.role', 'DOCTOR');
    }

    public function test_staff_dashboard_requires_authentication(): void
    {
        $response = $this->getJson('/api/staff/dashboard');

        $response->assertUnauthorized()
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'Unauthenticated.');
    }

    public function test_doctor_receives_structured_dashboard_from_canonical_and_legacy_routes(): void
    {
        $doctor = User::factory()->doctor()->create([
            'full_name' => 'Dr. Ahmed Hassan',
            'last_login_at' => now()->subHours(6),
        ]);
        $this->grantPermissions($doctor, [
            'lectures.create',
            'section_content.create',
            'quizzes.create',
            'tasks.create',
            'tasks.view',
            'community.post',
        ], canManageGrades: true);

        [
            'subject' => $subject,
            'offering' => $offering,
            'group' => $group,
            'students' => [$studentA, $studentB],
        ] = $this->createTeachingContext($doctor);

        ScheduleEvent::query()->create([
            'course_offering_id' => $offering->id,
            'subject_id' => $subject->id,
            'staff_user_id' => $doctor->id,
            'type' => 'LECTURE',
            'event_type' => 'LECTURE',
            'title' => 'Week 6 Lecture',
            'event_date' => now()->toDateString(),
            'day_of_week' => now()->dayOfWeek,
            'start_time' => '09:00:00',
            'end_time' => '11:00:00',
            'location' => 'Hall B2',
            'week_pattern' => 'ALL',
        ]);

        Quiz::query()->create([
            'subject_id' => $subject->id,
            'created_by' => $doctor->id,
            'week_number' => 6,
            'title' => 'Sprint Planning Quiz',
            'quiz_date' => now()->addDay()->toDateString(),
            'is_published' => false,
        ]);

        $task = Task::query()->create([
            'subject_id' => $subject->id,
            'created_by' => $doctor->id,
            'week_number' => 6,
            'title' => 'Iteration Assignment',
            'due_date' => now()->subDay()->toDateString(),
            'is_published' => true,
        ]);

        TaskSubmission::query()->create([
            'task_id' => $task->id,
            'student_user_id' => $studentB->id,
            'status' => 'submitted',
            'submitted_at' => now()->subHours(3),
        ]);

        GradeItem::query()->create([
            'course_offering_id' => $offering->id,
            'student_user_id' => $studentA->id,
            'type' => GradeType::TASK,
            'score' => 8,
            'max_score' => 20,
            'updated_by' => $doctor->id,
        ]);

        $post = Post::query()->create([
            'group_id' => $group->id,
            'author_user_id' => $studentB->id,
            'content_text' => 'Can you review the task notes?',
        ]);

        Comment::query()->create([
            'post_id' => $post->id,
            'author_user_id' => $studentB->id,
            'text' => 'I also have a question about grading.',
        ]);

        Message::query()->create([
            'group_id' => $group->id,
            'sender_user_id' => $studentB->id,
            'text' => 'We uploaded our draft.',
        ]);

        UserNotification::query()->create([
            'target_user_id' => $doctor->id,
            'title' => 'New student question',
            'body' => 'A student commented on Software Engineering.',
            'type' => 'SYSTEM',
            'category' => 'group',
            'is_read' => false,
        ]);

        $canonical = $this->actingAs($doctor)->getJson('/api/staff/dashboard');
        $legacy = $this->actingAs($doctor)->getJson('/api/staff-portal/dashboard');

        $canonical->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.header.user.role', 'DOCTOR')
            ->assertJsonPath('data.notifications_preview.unread_count', 1)
            ->assertJsonPath('data.pending_grading.can_manage', true)
            ->assertJsonPath('data.pending_grading.count', 1)
            ->assertJsonPath('data.student_activity_insights.missing_submissions', 1)
            ->assertJsonPath('data.performance_analytics.average_score', 40)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'header' => ['user', 'notification_badge', 'generated_at'],
                    'quick_actions',
                    'action_center' => ['summary', 'items'],
                    'today_focus' => ['headline', 'summary', 'metrics'],
                    'timeline' => ['groups'],
                    'subjects_overview' => ['summary', 'items'],
                    'students_attention' => ['count', 'items'],
                    'student_activity_insights',
                    'course_health',
                    'group_activity_feed' => ['items'],
                    'notifications_preview' => ['unread_count', 'items'],
                    'pending_grading',
                    'performance_analytics',
                    'risk_alerts',
                    'weekly_summary',
                    'smart_suggestions',
                ],
            ]);

        $this->assertSame(
            $canonical->json('data.header.user.name'),
            $legacy->json('data.header.user.name'),
        );
        $this->assertSame(
            $canonical->json('data.action_center.summary'),
            $legacy->json('data.action_center.summary'),
        );
        $this->assertNotEmpty($canonical->json('data.action_center.items'));
        $this->assertGreaterThan(0, $canonical->json('data.risk_alerts.count'));
        $this->assertLessThan(100, $canonical->json('data.course_health.overall_score'));
    }

    public function test_assistant_receives_permission_filtered_dashboard(): void
    {
        $assistant = User::factory()->teachingAssistant()->create([
            'full_name' => 'Mona Assistant',
            'last_login_at' => now()->subDays(2),
        ]);
        $this->grantPermissions($assistant, [
            'tasks.view',
            'community.post',
        ]);

        ['subject' => $subject, 'offering' => $offering] = $this->createTeachingContext(
            $assistant,
            isAssistantOwner: true,
        );

        ScheduleEvent::query()->create([
            'course_offering_id' => $offering->id,
            'subject_id' => $subject->id,
            'staff_user_id' => $assistant->id,
            'type' => 'SECTION',
            'event_type' => 'SECTION',
            'title' => 'Lab 4',
            'event_date' => now()->addDay()->toDateString(),
            'day_of_week' => now()->addDay()->dayOfWeek,
            'start_time' => '11:00:00',
            'end_time' => '13:00:00',
            'location' => 'Lab C1',
            'week_pattern' => 'ALL',
        ]);

        $task = Task::query()->create([
            'subject_id' => $subject->id,
            'created_by' => $assistant->id,
            'week_number' => 6,
            'title' => 'Worksheet',
            'due_date' => now()->subDay()->toDateString(),
            'is_published' => false,
        ]);

        TaskSubmission::query()->create([
            'task_id' => $task->id,
            'student_user_id' => User::factory()->create()->id,
            'status' => 'submitted',
            'submitted_at' => now()->subHours(2),
        ]);

        $response = $this->actingAs($assistant)->getJson('/api/staff/dashboard');

        $response->assertOk()
            ->assertJsonPath('data.header.user.role', 'ASSISTANT')
            ->assertJsonPath('data.pending_grading.can_manage', false)
            ->assertJsonPath('data.performance_analytics.is_limited', true);

        $quickActionIds = collect($response->json('data.quick_actions'))->pluck('id')->all();
        $actionTypes = collect($response->json('data.action_center.items'))->pluck('type')->all();

        $this->assertContains('send_announcement', $quickActionIds);
        $this->assertNotContains('add_quiz', $quickActionIds);
        $this->assertNotContains('add_task', $quickActionIds);
        $this->assertNotContains('PENDING_GRADING', $actionTypes);
        $this->assertNotContains('TASK_UNPUBLISHED', $actionTypes);
        $this->assertNotContains('QUIZ_UNPUBLISHED', $actionTypes);
    }

    public function test_student_cannot_access_staff_dashboard(): void
    {
        $student = User::factory()->create();

        $response = $this->actingAs($student)->getJson('/api/staff/dashboard');

        $response->assertForbidden()
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'Doctor or assistant access required.');
    }

    public function test_empty_staff_account_still_gets_valid_structured_payload(): void
    {
        $doctor = User::factory()->doctor()->create([
            'full_name' => 'Dr. Empty',
        ]);
        $this->grantPermissions($doctor, ['lectures.create']);

        $response = $this->actingAs($doctor)->getJson('/api/staff/dashboard');

        $response->assertOk()
            ->assertJsonPath('data.header.user.name', 'Dr. Empty')
            ->assertJsonPath('data.action_center.items', [])
            ->assertJsonPath('data.subjects_overview.items', [])
            ->assertJsonPath('data.notifications_preview.items', [])
            ->assertJsonCount(3, 'data.timeline.groups');
    }

    public function test_missing_submission_logic_counts_full_class_when_no_one_submits(): void
    {
        $doctor = User::factory()->doctor()->create([
            'full_name' => 'Dr. Missing',
        ]);
        $this->grantPermissions($doctor, ['tasks.view', 'tasks.create']);

        ['subject' => $subject] = $this->createTeachingContext($doctor, studentsCount: 3);

        Task::query()->create([
            'subject_id' => $subject->id,
            'created_by' => $doctor->id,
            'week_number' => 6,
            'title' => 'Zero Submission Task',
            'due_date' => now()->subDay()->toDateString(),
            'is_published' => true,
        ]);

        $response = $this->actingAs($doctor)->getJson('/api/staff/dashboard');

        $response->assertOk()
            ->assertJsonPath('data.student_activity_insights.missing_submissions', 3);

        $actionTitles = collect($response->json('data.action_center.items'))->pluck('title')->implode(' | ');
        $this->assertStringContainsString('3 students did not submit', $actionTitles);
    }

    private function grantPermissions(
        User $user,
        array $permissions,
        bool $canManageGrades = false,
    ): void {
        $permissionIds = collect($permissions)
            ->map(fn (string $name) => Permission::query()->firstOrCreate([
                'name' => $name,
            ], [
                'group_name' => 'testing',
                'label' => $name,
            ])->id)
            ->all();

        $user->permissions()->sync($permissionIds);

        StaffPermission::query()->updateOrCreate(
            ['user_id' => $user->id],
            [
                'can_upload_content' => true,
                'can_manage_grades' => $canManageGrades,
                'can_manage_schedule' => true,
                'can_moderate_group' => true,
            ],
        );
    }

    private function createTeachingContext(
        User $staff,
        bool $isAssistantOwner = false,
        int $studentsCount = 2,
    ): array {
        $department = Department::factory()->create(['name' => 'Computer Science']);
        $section = Section::factory()->create([
            'department_id' => $department->id,
            'grade_year' => 3,
        ]);

        $subject = Subject::factory()->create([
            'department_id' => $department->id,
            'name' => 'Software Engineering',
            'grade_year' => 3,
            'semester' => Semester::SECOND,
        ]);

        $offering = CourseOffering::query()->create([
            'subject_id' => $subject->id,
            'section_id' => $section->id,
            'doctor_user_id' => $isAssistantOwner ? null : $staff->id,
            'ta_user_id' => $isAssistantOwner ? $staff->id : null,
            'academic_year' => '2025/2026',
            'semester' => Semester::SECOND,
        ]);

        $group = GroupChat::query()->create([
            'course_offering_id' => $offering->id,
            'name' => 'SE Group',
            'description' => 'Software Engineering group',
            'created_by' => $staff->id,
        ]);
        $offering->update(['group_id' => $group->id]);

        $students = collect();
        for ($index = 0; $index < $studentsCount; $index++) {
            $student = User::factory()->create([
                'full_name' => 'Student '.($index + 1),
                'last_login_at' => $index === 0 ? now()->subDays(12) : now(),
            ]);

            Enrollment::query()->create([
                'course_offering_id' => $offering->id,
                'student_user_id' => $student->id,
                'status' => Enrollment::STATUS_ENROLLED,
            ]);

            $students->push($student);
        }

        return [
            'subject' => $subject,
            'offering' => $offering->fresh(),
            'group' => $group,
            'students' => $students->all(),
        ];
    }
}
