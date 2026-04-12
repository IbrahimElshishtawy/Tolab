<?php

namespace Tests\Feature;

use App\Core\Enums\Semester;
use App\Core\Enums\UserRole;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Academic\Models\Department;
use App\Modules\Academic\Models\Section;
use App\Modules\Academic\Models\Subject;
use App\Modules\Enrollment\Models\Enrollment;
use App\Modules\Group\Models\Comment;
use App\Modules\Group\Models\GroupChat;
use App\Modules\Group\Models\Message;
use App\Modules\Group\Models\Post;
use App\Modules\Notifications\Models\UserNotification;
use App\Modules\Schedule\Models\ScheduleEvent;
use App\Modules\StaffPortal\Models\Quiz;
use App\Modules\StaffPortal\Models\Task;
use App\Modules\StaffPortal\Models\TaskSubmission;
use App\Modules\UserManagement\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class StaffDashboardTest extends TestCase
{
    use RefreshDatabase;

    public function test_doctor_dashboard_returns_actionable_payload(): void
    {
        $doctor = User::factory()->doctor()->create([
            'full_name' => 'Dr. Ahmed Hassan',
            'role' => UserRole::DOCTOR,
            'role_type' => 'doctor',
            'last_login_at' => now()->subHours(6),
        ]);

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
            'doctor_user_id' => $doctor->id,
            'academic_year' => '2025/2026',
            'semester' => Semester::SECOND,
        ]);

        $group = GroupChat::query()->create([
            'course_offering_id' => $offering->id,
            'name' => 'SE Group',
            'description' => 'Software Engineering group',
            'created_by' => $doctor->id,
        ]);
        $offering->update(['group_id' => $group->id]);

        $studentA = User::factory()->create([
            'full_name' => 'Omar Ali',
            'last_login_at' => now()->subDays(11),
        ]);
        $studentB = User::factory()->create([
            'full_name' => 'Mona Adel',
            'last_login_at' => now(),
        ]);

        Enrollment::query()->create([
            'course_offering_id' => $offering->id,
            'student_user_id' => $studentA->id,
            'status' => Enrollment::STATUS_ENROLLED,
        ]);
        Enrollment::query()->create([
            'course_offering_id' => $offering->id,
            'student_user_id' => $studentB->id,
            'status' => Enrollment::STATUS_ENROLLED,
        ]);

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

        $response = $this->actingAs($doctor)->getJson('/api/staff-portal/dashboard');

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.user.role', 'DOCTOR')
            ->assertJsonPath('data.notifications.unread_count', 1)
            ->assertJsonPath('data.today_stats.lectures', 1)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'user' => ['id', 'name', 'role', 'greeting', 'subtitle'],
                    'quick_actions',
                    'notifications' => ['unread_count', 'latest'],
                    'today_stats' => ['lectures', 'sections', 'quizzes', 'tasks'],
                    'action_required',
                    'today_schedule',
                    'upcoming',
                    'subjects_preview',
                    'group_activity',
                    'student_insights' => [
                        'active_students',
                        'inactive_students',
                        'missing_submissions',
                        'new_comments',
                        'unread_messages',
                        'needs_attention',
                    ],
                ],
            ]);

        $this->assertNotEmpty($response->json('data.action_required'));
    }

    public function test_student_cannot_access_staff_dashboard(): void
    {
        $student = User::factory()->create();

        $response = $this->actingAs($student)->getJson('/api/staff-portal/dashboard');

        $response->assertForbidden()
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'Doctor or assistant access required.');
    }
}
