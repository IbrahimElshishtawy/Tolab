<?php

namespace App\Modules\StaffPortal\Services;

use App\Core\Enums\UserRole;
use App\Core\Enums\WeekPattern;
use App\Core\Exceptions\ApiException;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Academic\Models\Subject;
use App\Modules\Content\Models\Lecture;
use App\Modules\Enrollment\Models\Enrollment;
use App\Modules\Group\Models\Comment;
use App\Modules\Group\Models\Message;
use App\Modules\Group\Models\Post;
use App\Modules\Notifications\Models\UserNotification;
use App\Modules\Schedule\Models\ScheduleEvent;
use App\Modules\StaffPortal\Models\AcademicSectionContent;
use App\Modules\StaffPortal\Models\Quiz;
use App\Modules\StaffPortal\Models\Task;
use App\Modules\StaffPortal\Models\TaskSubmission;
use App\Modules\UserManagement\Models\User;
use Carbon\CarbonImmutable;
use Illuminate\Database\Eloquent\Collection as EloquentCollection;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Cache;
use Symfony\Component\HttpFoundation\Response;

class DashboardService
{
    public function dashboard(User $user): array
    {
        $this->ensureStaffRole($user);

        return Cache::remember(
            sprintf('staff-dashboard:%d', $user->id),
            now()->addSeconds(45),
            fn () => $this->buildDashboard($user),
        );
    }

    protected function buildDashboard(User $user): array
    {
        $today = CarbonImmutable::now();
        $managedOfferings = $this->managedOfferings($user);
        $subjectIds = $managedOfferings->pluck('subject_id')
            ->merge($user->staffAssignments()->pluck('subject_id'))
            ->filter()
            ->map(fn ($id) => (int) $id)
            ->unique()
            ->values();

        $subjects = Subject::query()
            ->with(['department', 'academicYear', 'sections.assistant'])
            ->whereIn('id', $subjectIds)
            ->orderBy('name')
            ->get();

        $scheduleEvents = ScheduleEvent::query()
            ->with(['courseOffering.subject', 'courseOffering.section', 'subject'])
            ->where(function ($query) use ($managedOfferings, $subjectIds, $user) {
                $query->whereIn('course_offering_id', $managedOfferings->pluck('id'))
                    ->orWhereIn('subject_id', $subjectIds)
                    ->orWhere('staff_user_id', $user->id);
            })
            ->get();

        $lectures = Lecture::query()
            ->with(['subject', 'author'])
            ->whereIn('subject_id', $subjectIds)
            ->latest('published_at')
            ->latest('created_at')
            ->get();

        $sectionContents = AcademicSectionContent::query()
            ->with(['subject', 'author'])
            ->whereIn('subject_id', $subjectIds)
            ->latest('published_at')
            ->latest('created_at')
            ->get();

        $quizzes = Quiz::query()
            ->with(['subject', 'author'])
            ->whereIn('subject_id', $subjectIds)
            ->latest('quiz_date')
            ->get();

        $tasks = Task::query()
            ->with(['subject', 'author'])
            ->whereIn('subject_id', $subjectIds)
            ->latest('due_date')
            ->get();

        $taskSubmissions = TaskSubmission::query()
            ->with(['task.subject', 'student'])
            ->whereIn('task_id', $tasks->pluck('id'))
            ->get();

        $enrollments = Enrollment::query()
            ->with(['student', 'courseOffering.subject'])
            ->active()
            ->whereIn('course_offering_id', $managedOfferings->pluck('id'))
            ->get();

        $notifications = UserNotification::query()
            ->where(function ($query) use ($user) {
                $query->where('target_user_id', $user->id)
                    ->orWhere('is_global', true);
            })
            ->latest()
            ->get();

        $groupIds = $managedOfferings->pluck('group_id')->filter()->values();

        $posts = Post::query()
            ->with(['author', 'group.courseOffering.subject'])
            ->whereIn('group_id', $groupIds)
            ->latest()
            ->limit(12)
            ->get();

        $comments = Comment::query()
            ->with(['author', 'post.group.courseOffering.subject'])
            ->whereHas('post', fn ($query) => $query->whereIn('group_id', $groupIds))
            ->latest()
            ->limit(12)
            ->get();

        $messages = Message::query()
            ->with(['sender', 'group.courseOffering.subject'])
            ->whereIn('group_id', $groupIds)
            ->latest()
            ->limit(12)
            ->get();

        $todaySchedule = $scheduleEvents
            ->filter(fn (ScheduleEvent $event) => $this->eventMatchesDate($event, $today))
            ->sortBy(fn (ScheduleEvent $event) => $this->timeSortKey($event))
            ->values();

        $missingSubmissionsByStudent = $this->missingSubmissionsByStudent(
            $tasks,
            $taskSubmissions,
            $enrollments,
        );

        return [
            'user' => $this->buildUserSummary($user, $subjects, $today),
            'quick_actions' => $this->buildQuickActions($user),
            'notifications' => $this->buildNotifications($notifications),
            'today_stats' => $this->buildTodayStats($todaySchedule, $quizzes, $tasks, $today),
            'action_required' => $this->buildActionRequired(
                $user,
                $subjects,
                $scheduleEvents,
                $lectures,
                $sectionContents,
                $quizzes,
                $tasks,
                $taskSubmissions,
                $enrollments,
                $today,
            ),
            'today_schedule' => $this->buildTodaySchedule($todaySchedule, $today),
            'upcoming' => $this->buildUpcoming($scheduleEvents, $tasks, $today),
            'subjects_preview' => $this->buildSubjectsPreview($subjects, $managedOfferings, $enrollments),
            'group_activity' => $this->buildGroupActivity($posts, $comments, $messages),
            'student_insights' => $this->buildStudentInsights(
                $user,
                $enrollments,
                $posts,
                $comments,
                $messages,
                $missingSubmissionsByStudent,
                $today,
            ),
        ];
    }

    protected function ensureStaffRole(User $user): void
    {
        if (! in_array($user->role, [UserRole::DOCTOR, UserRole::TA], true)) {
            throw new ApiException('Doctor or assistant access required.', [], Response::HTTP_FORBIDDEN);
        }
    }

    protected function managedOfferings(User $user): EloquentCollection
    {
        return CourseOffering::query()
            ->with(['subject.department', 'subject.academicYear', 'section', 'group'])
            ->when(
                $user->role === UserRole::DOCTOR,
                fn ($query) => $query->where('doctor_user_id', $user->id),
                fn ($query) => $query->where('ta_user_id', $user->id),
            )
            ->get();
    }

    protected function buildUserSummary(User $user, Collection $subjects, CarbonImmutable $today): array
    {
        $greeting = match (true) {
            $today->hour < 12 => 'Good morning',
            $today->hour < 17 => 'Good afternoon',
            default => 'Good evening',
        };

        return [
            'id' => $user->id,
            'name' => $user->full_name ?: $user->username,
            'role' => $user->role === UserRole::DOCTOR ? 'DOCTOR' : 'ASSISTANT',
            'avatar' => $user->avatar,
            'greeting' => sprintf('%s, %s', $greeting, $user->full_name ?: $user->username),
            'subtitle' => 'Here is your academic overview for today.',
            'departments' => $subjects->pluck('department.name')->filter()->unique()->values()->all(),
            'academic_years' => $subjects->pluck('academicYear.name')->filter()->unique()->values()->all(),
        ];
    }

    protected function buildQuickActions(User $user): array
    {
        $actions = [
            ['id' => 'add_lecture', 'label' => 'Add Lecture', 'description' => 'Publish a lecture item for your subject.', 'route' => '/workspace/lectures', 'permission' => 'lectures.create'],
            ['id' => 'add_section', 'label' => 'Add Section', 'description' => 'Upload section or lab content quickly.', 'route' => '/workspace/sections', 'permission' => 'section_content.create'],
            ['id' => 'add_quiz', 'label' => 'Add Quiz', 'description' => 'Prepare an assessment or quiz window.', 'route' => '/workspace/quizzes', 'permission' => 'quizzes.create'],
            ['id' => 'add_task', 'label' => 'Add Task', 'description' => 'Create a task with a student deadline.', 'route' => '/workspace/tasks', 'permission' => 'tasks.create'],
            ['id' => 'add_post', 'label' => 'Add Post', 'description' => 'Open a subject workspace to post an update.', 'route' => '/workspace/subjects', 'permission' => 'community.post'],
        ];

        return collect($actions)
            ->filter(fn (array $action) => $action['id'] === 'add_post' || $user->hasPermission($action['permission']))
            ->values()
            ->all();
    }

    protected function buildNotifications(EloquentCollection $notifications): array
    {
        return [
            'unread_count' => $notifications->where('is_read', false)->count(),
            'latest' => $notifications->take(5)->map(fn (UserNotification $notification) => [
                'id' => $notification->id,
                'title' => $notification->title,
                'body' => $notification->body,
                'time' => optional($notification->created_at)->toIso8601String(),
                'is_unread' => ! $notification->is_read,
                'category' => $notification->category ?: $notification->type?->value,
                'route' => '/workspace/notifications',
            ])->values()->all(),
        ];
    }

    protected function buildTodayStats(
        Collection $todaySchedule,
        EloquentCollection $quizzes,
        EloquentCollection $tasks,
        CarbonImmutable $today,
    ): array {
        return [
            'lectures' => $todaySchedule->filter(
                fn (ScheduleEvent $event) => strtoupper((string) ($event->event_type ?: $event->type?->value ?: $event->type)) === 'LECTURE',
            )->count(),
            'sections' => $todaySchedule->filter(
                fn (ScheduleEvent $event) => strtoupper((string) ($event->event_type ?: $event->type?->value ?: $event->type)) === 'SECTION',
            )->count(),
            'quizzes' => $quizzes->filter(fn (Quiz $quiz) => $quiz->quiz_date?->isSameDay($today) === true)->count(),
            'tasks' => $tasks->filter(fn (Task $task) => $task->due_date?->isSameDay($today) === true)->count(),
        ];
    }

    protected function buildActionRequired(
        User $user,
        Collection $subjects,
        Collection $scheduleEvents,
        EloquentCollection $lectures,
        EloquentCollection $sectionContents,
        EloquentCollection $quizzes,
        EloquentCollection $tasks,
        EloquentCollection $taskSubmissions,
        EloquentCollection $enrollments,
        CarbonImmutable $today,
    ): array {
        $items = collect();
        $windowEnd = $today->addDays(2)->endOfDay();

        foreach ($scheduleEvents as $event) {
            $startAt = $this->nextOccurrence($event, $today);
            if ($startAt === null || $startAt->greaterThan($windowEnd)) {
                continue;
            }

            $eventType = strtoupper((string) ($event->event_type ?: $event->type?->value ?: $event->type));
            $subjectId = (int) ($event->subject_id ?: $event->courseOffering?->subject_id);
            $subjectName = $event->courseOffering?->subject?->name ?: $subjects->firstWhere('id', $subjectId)?->name;

            if ($eventType === 'LECTURE' && $user->role === UserRole::DOCTOR) {
                $recentLecture = $lectures
                    ->where('subject_id', $subjectId)
                    ->where('is_published', true)
                    ->first(fn (Lecture $lecture) => $lecture->published_at?->greaterThanOrEqualTo($today->subDays(14)));

                if (! $recentLecture) {
                    $items->push($this->actionItem(
                        'lecture_missing_'.$event->id,
                        'LECTURE_MISSING',
                        'HIGH',
                        sprintf('%s lecture still needs content', $subjectName ?: 'Upcoming lecture'),
                        'A lecture is scheduled soon, but no recently published lecture content was found.',
                        'Upload',
                        '/workspace/lectures',
                        ['subject_id' => $subjectId, 'event_id' => $event->id],
                    ));
                }
            }

            if ($eventType === 'SECTION' && $user->role === UserRole::TA) {
                $recentSection = $sectionContents
                    ->where('subject_id', $subjectId)
                    ->where('is_published', true)
                    ->first(fn (AcademicSectionContent $content) => $content->published_at?->greaterThanOrEqualTo($today->subDays(14)));

                if (! $recentSection) {
                    $items->push($this->actionItem(
                        'section_missing_'.$event->id,
                        'SECTION_CONTENT_MISSING',
                        'HIGH',
                        sprintf('%s section content is missing', $subjectName ?: 'Upcoming section'),
                        'A section session is close, but no recent published section content was found.',
                        'Upload',
                        '/workspace/sections',
                        ['subject_id' => $subjectId, 'event_id' => $event->id],
                    ));
                }
            }
        }

        foreach ($quizzes as $quiz) {
            if (! $quiz->is_published && $quiz->quiz_date !== null && $quiz->quiz_date->between($today->startOfDay(), $today->addDays(7)->endOfDay())) {
                $items->push($this->actionItem(
                    'quiz_unpublished_'.$quiz->id,
                    'QUIZ_UNPUBLISHED',
                    'HIGH',
                    sprintf('%s quiz is still unpublished', $quiz->subject?->name ?: 'Upcoming quiz'),
                    'The quiz date is approaching and students still cannot access it.',
                    'Publish',
                    '/workspace/quizzes',
                    ['subject_id' => $quiz->subject_id, 'quiz_id' => $quiz->id],
                ));
            }
        }

        foreach ($tasks as $task) {
            if (! $task->is_published) {
                $items->push($this->actionItem(
                    'task_unpublished_'.$task->id,
                    'TASK_UNPUBLISHED',
                    'HIGH',
                    sprintf('%s task is still unpublished', $task->subject?->name ?: 'Task'),
                    'Students cannot see this task yet.',
                    'Publish',
                    '/workspace/tasks',
                    ['subject_id' => $task->subject_id, 'task_id' => $task->id],
                ));
            } elseif ($task->due_date !== null && $task->due_date->between($today->startOfDay(), $today->addDays(3)->endOfDay())) {
                $items->push($this->actionItem(
                    'task_deadline_'.$task->id,
                    'TASK_NEARING_DEADLINE',
                    'MEDIUM',
                    sprintf('%s deadline is close', $task->title),
                    'This task deadline is near and may need student follow-up.',
                    'Review',
                    '/workspace/tasks',
                    ['subject_id' => $task->subject_id, 'task_id' => $task->id],
                ));
            }
        }

        $pendingGrading = $taskSubmissions
            ->filter(fn (TaskSubmission $submission) => $submission->submitted_at !== null && $submission->graded_at === null)
            ->groupBy('task_id');

        foreach ($pendingGrading as $taskId => $submissions) {
            $task = $tasks->firstWhere('id', (int) $taskId);
            if (! $task) {
                continue;
            }

            $items->push($this->actionItem(
                'grading_pending_'.$taskId,
                'PENDING_GRADING',
                'HIGH',
                sprintf('%d submissions need grading', $submissions->count()),
                sprintf('Task "%s" still has work waiting for review.', $task->title),
                'Review',
                '/workspace/tasks',
                ['subject_id' => $task->subject_id, 'task_id' => $task->id],
            ));
        }

        foreach ($this->missingSubmissionsByTask($tasks, $taskSubmissions, $enrollments) as $taskId => $missingCount) {
            $task = $tasks->firstWhere('id', (int) $taskId);
            if (! $task || $missingCount < 1) {
                continue;
            }

            $items->push($this->actionItem(
                'missing_submissions_'.$taskId,
                'MISSING_SUBMISSIONS',
                'HIGH',
                sprintf('%d students did not submit', $missingCount),
                sprintf('Task "%s" still has missing student submissions.', $task->title),
                'Open',
                '/workspace/tasks',
                ['subject_id' => $task->subject_id, 'task_id' => $task->id],
            ));
        }

        $priorityOrder = ['HIGH' => 0, 'MEDIUM' => 1, 'LOW' => 2];

        return $items
            ->unique('id')
            ->sortBy(fn (array $item) => $priorityOrder[$item['priority']] ?? 9)
            ->take(8)
            ->values()
            ->all();
    }

    protected function buildTodaySchedule(Collection $todaySchedule, CarbonImmutable $today): array
    {
        return $todaySchedule->map(function (ScheduleEvent $event) use ($today) {
            $subjectName = $event->courseOffering?->subject?->name ?: $event->subject?->name ?: $event->title;
            $when = $this->nextOccurrence($event, $today) ?? $today;

            return [
                'id' => $event->id,
                'type' => strtoupper((string) ($event->event_type ?: $event->type?->value ?: $event->type)),
                'title' => $event->title ?: $subjectName,
                'subject_name' => $subjectName,
                'time' => sprintf('%s - %s', substr((string) $event->start_time, 0, 5), substr((string) $event->end_time, 0, 5)),
                'location' => $event->location ?: 'Online',
                'status' => $event->location ? 'ROOM' : 'ONLINE',
                'date' => $when->toDateString(),
                'route' => '/workspace/schedule',
            ];
        })->values()->all();
    }

    protected function buildUpcoming(Collection $scheduleEvents, EloquentCollection $tasks, CarbonImmutable $today): array
    {
        $items = collect();

        foreach (['LECTURE', 'SECTION', 'QUIZ'] as $type) {
            $nextEvent = $scheduleEvents
                ->filter(fn (ScheduleEvent $event) => strtoupper((string) ($event->event_type ?: $event->type?->value ?: $event->type)) === $type)
                ->map(fn (ScheduleEvent $event) => ['event' => $event, 'when' => $this->nextOccurrence($event, $today)])
                ->filter(fn (array $item) => $item['when'] !== null)
                ->sortBy(fn (array $item) => $item['when']->timestamp)
                ->first();

            if ($nextEvent) {
                $event = $nextEvent['event'];
                $when = $nextEvent['when'];

                $items->push([
                    'id' => sprintf('%s_%d', strtolower($type), $event->id),
                    'type' => $type,
                    'subject_name' => $event->courseOffering?->subject?->name ?: $event->title,
                    'title' => $event->title ?: ($event->courseOffering?->subject?->name ?: $type),
                    'date_time' => $when->toIso8601String(),
                    'status' => $when->isToday() ? 'TODAY' : 'UPCOMING',
                    'cta' => 'Open',
                    'route' => '/workspace/schedule',
                ]);
            }
        }

        $nextTask = $tasks
            ->filter(fn (Task $task) => $task->due_date !== null && $task->due_date->greaterThanOrEqualTo($today))
            ->sortBy(fn (Task $task) => $task->due_date?->timestamp)
            ->first();

        if ($nextTask) {
            $items->push([
                'id' => 'task_'.$nextTask->id,
                'type' => 'TASK',
                'subject_name' => $nextTask->subject?->name ?: $nextTask->title,
                'title' => $nextTask->title,
                'date_time' => $nextTask->due_date?->toIso8601String(),
                'status' => $nextTask->due_date?->isToday() === true ? 'DUE_TODAY' : 'OPEN',
                'cta' => 'Review',
                'route' => '/workspace/tasks',
            ]);
        }

        return $items->values()->all();
    }

    protected function buildSubjectsPreview(Collection $subjects, EloquentCollection $managedOfferings, EloquentCollection $enrollments): array
    {
        return $subjects->take(4)->map(function (Subject $subject) use ($managedOfferings, $enrollments) {
            $subjectOfferings = $managedOfferings->where('subject_id', $subject->id);
            $studentCount = $subjectOfferings->sum(
                fn (CourseOffering $offering) => $enrollments->where('course_offering_id', $offering->id)->count(),
            );

            return [
                'id' => $subject->id,
                'name' => $subject->name,
                'code' => $subject->code,
                'department' => $subject->department?->name,
                'academic_year' => $subject->academicYear?->name ?: (string) $subject->grade_year,
                'batch' => 'Level '.($subject->grade_year ?: $subject->academicYear?->level ?: 1),
                'student_count' => $studentCount,
                'groups_count' => $subjectOfferings->whereNotNull('group_id')->count(),
                'sections_count' => $subjectOfferings->pluck('section_id')->filter()->unique()->count(),
                'routes' => [
                    ['label' => 'Open Subject', 'route' => sprintf('/workspace/subjects/%d', $subject->id)],
                    ['label' => 'Add Lecture', 'route' => '/workspace/lectures'],
                    ['label' => 'View Group', 'route' => sprintf('/workspace/subjects/%d', $subject->id)],
                    ['label' => 'Open Chat', 'route' => sprintf('/workspace/subjects/%d', $subject->id)],
                ],
            ];
        })->values()->all();
    }

    protected function buildGroupActivity(EloquentCollection $posts, EloquentCollection $comments, EloquentCollection $messages): array
    {
        $items = collect();

        foreach ($posts as $post) {
            $items->push($this->activityItem(
                'post_'.$post->id,
                'POST',
                $post->group?->courseOffering?->subject?->name,
                $post->group?->name,
                $post->author?->full_name ?: $post->author?->username,
                $post->content_text,
                optional($post->created_at)->toIso8601String(),
            ));
        }

        foreach ($comments as $comment) {
            $items->push($this->activityItem(
                'comment_'.$comment->id,
                'COMMENT',
                $comment->post?->group?->courseOffering?->subject?->name,
                $comment->post?->group?->name,
                $comment->author?->full_name ?: $comment->author?->username,
                $comment->text,
                optional($comment->created_at)->toIso8601String(),
            ));
        }

        foreach ($messages as $message) {
            $items->push($this->activityItem(
                'message_'.$message->id,
                'MESSAGE',
                $message->group?->courseOffering?->subject?->name,
                $message->group?->name,
                $message->sender?->full_name ?: $message->sender?->username,
                $message->text,
                optional($message->created_at)->toIso8601String(),
            ));
        }

        return $items
            ->filter(fn (array $item) => ! empty($item['timestamp']))
            ->sortByDesc('timestamp')
            ->take(5)
            ->values()
            ->all();
    }

    protected function buildStudentInsights(
        User $staffUser,
        EloquentCollection $enrollments,
        EloquentCollection $posts,
        EloquentCollection $comments,
        EloquentCollection $messages,
        Collection $missingSubmissionsByStudent,
        CarbonImmutable $today,
    ): array {
        $students = $enrollments->pluck('student')->filter()->unique('id')->values();

        $todayStudentActivity = collect()
            ->merge($posts->filter(fn (Post $post) => $post->created_at?->isToday() && $post->author?->isStudent())->pluck('author_user_id'))
            ->merge($comments->filter(fn (Comment $comment) => $comment->created_at?->isToday() && $comment->author?->isStudent())->pluck('author_user_id'))
            ->merge($messages->filter(fn (Message $message) => $message->created_at?->isToday() && $message->sender?->isStudent())->pluck('sender_user_id'))
            ->filter()
            ->unique();

        $recentActivity = collect()
            ->merge($posts->filter(fn (Post $post) => $post->created_at?->greaterThanOrEqualTo($today->subDays(7)) && $post->author?->isStudent())->pluck('author_user_id'))
            ->merge($comments->filter(fn (Comment $comment) => $comment->created_at?->greaterThanOrEqualTo($today->subDays(7)) && $comment->author?->isStudent())->pluck('author_user_id'))
            ->merge($messages->filter(fn (Message $message) => $message->created_at?->greaterThanOrEqualTo($today->subDays(7)) && $message->sender?->isStudent())->pluck('sender_user_id'))
            ->filter()
            ->countBy();

        $activeStudents = $students
            ->filter(fn (User $student) => $student->last_login_at?->isToday() || $todayStudentActivity->contains($student->id))
            ->count();

        $inactiveStudents = $students
            ->filter(function (User $student) use ($today, $recentActivity) {
                $staleLogin = $student->last_login_at === null || $student->last_login_at->lessThan($today->subDays(14));
                return $staleLogin && ! $recentActivity->has($student->id);
            })
            ->count();

        $needsAttention = $students
            ->map(function (User $student) use ($today, $recentActivity, $missingSubmissionsByStudent) {
                $reasons = [];
                $missingCount = (int) ($missingSubmissionsByStudent[$student->id] ?? 0);
                if ($missingCount > 0) {
                    $reasons[] = sprintf('Missed %d task submissions', $missingCount);
                }
                if ($student->last_login_at === null || $student->last_login_at->lessThan($today->subDays(10))) {
                    $days = $student->last_login_at?->diffInDays($today) ?? 999;
                    $reasons[] = sprintf('No login in %d days', $days);
                }
                if (($recentActivity[$student->id] ?? 0) === 0) {
                    $reasons[] = 'Low group engagement this week';
                }

                if ($reasons === []) {
                    return null;
                }

                return [
                    'student_id' => $student->id,
                    'name' => $student->full_name ?: $student->username,
                    'reason' => $reasons[0],
                    'details' => $reasons,
                ];
            })
            ->filter()
            ->take(5)
            ->values();

        $reference = $staffUser->last_login_at ?? $today->subDay();
        $unreadMessages = $messages
            ->filter(fn (Message $message) => $message->created_at?->greaterThan($reference) && $message->sender_user_id !== $staffUser->id)
            ->count();

        return [
            'active_students' => $activeStudents,
            'inactive_students' => $inactiveStudents,
            'missing_submissions' => $missingSubmissionsByStudent->sum(),
            'new_comments' => $comments->filter(fn (Comment $comment) => $comment->created_at?->greaterThanOrEqualTo($today->subDay()))->count(),
            'unread_messages' => $unreadMessages,
            'low_engagement_count' => $students->filter(fn (User $student) => ($recentActivity[$student->id] ?? 0) === 0)->count(),
            'students_needing_attention' => $needsAttention->count(),
            'needs_attention' => $needsAttention->all(),
        ];
    }

    protected function missingSubmissionsByTask(
        EloquentCollection $tasks,
        EloquentCollection $taskSubmissions,
        EloquentCollection $enrollments,
    ): Collection {
        $studentIdsBySubject = $enrollments
            ->groupBy(fn (Enrollment $enrollment) => $enrollment->courseOffering?->subject_id)
            ->map(fn (Collection $group) => $group->pluck('student_user_id')->filter()->unique()->values());

        return $tasks
            ->filter(fn (Task $task) => $task->is_published && $task->due_date !== null && $task->due_date->isPast())
            ->mapWithKeys(function (Task $task) use ($taskSubmissions, $studentIdsBySubject) {
                $subjectStudentIds = $studentIdsBySubject->get($task->subject_id, collect());
                $submittedStudentIds = $taskSubmissions
                    ->where('task_id', $task->id)
                    ->pluck('student_user_id')
                    ->filter()
                    ->unique();

                if ($submittedStudentIds->isEmpty()) {
                    return [$task->id => 0];
                }

                return [$task->id => max($subjectStudentIds->count() - $submittedStudentIds->count(), 0)];
            });
    }

    protected function missingSubmissionsByStudent(
        EloquentCollection $tasks,
        EloquentCollection $taskSubmissions,
        EloquentCollection $enrollments,
    ): Collection {
        $byStudent = collect();
        $studentIdsBySubject = $enrollments
            ->groupBy(fn (Enrollment $enrollment) => $enrollment->courseOffering?->subject_id)
            ->map(fn (Collection $group) => $group->pluck('student_user_id')->filter()->unique()->values());

        foreach ($tasks as $task) {
            if (! $task->is_published || $task->due_date === null || ! $task->due_date->isPast()) {
                continue;
            }

            $submittedIds = $taskSubmissions
                ->where('task_id', $task->id)
                ->pluck('student_user_id')
                ->filter()
                ->unique();

            if ($submittedIds->isEmpty()) {
                continue;
            }

            $studentIdsBySubject->get($task->subject_id, collect())
                ->diff($submittedIds)
                ->each(function ($studentId) use ($byStudent) {
                    $byStudent[$studentId] = ((int) ($byStudent[$studentId] ?? 0)) + 1;
                });
        }

        return $byStudent;
    }

    protected function eventMatchesDate(ScheduleEvent $event, CarbonImmutable $date): bool
    {
        if ($event->event_date !== null) {
            return $event->event_date->isSameDay($date);
        }

        if ($event->day_of_week !== $date->dayOfWeek) {
            return false;
        }

        return match ($event->week_pattern) {
            WeekPattern::ODD => $date->weekOfYear % 2 === 1,
            WeekPattern::EVEN => $date->weekOfYear % 2 === 0,
            default => true,
        };
    }

    protected function nextOccurrence(ScheduleEvent $event, CarbonImmutable $from): ?CarbonImmutable
    {
        if ($event->event_date !== null) {
            if ($event->event_date->lessThan($from->startOfDay())) {
                return null;
            }

            return $this->dateTimeForEvent($event->event_date->toImmutable(), (string) $event->start_time);
        }

        for ($offset = 0; $offset <= 14; $offset++) {
            $candidate = $from->addDays($offset);
            if ($this->eventMatchesDate($event, $candidate)) {
                return $this->dateTimeForEvent($candidate, (string) $event->start_time);
            }
        }

        return null;
    }

    protected function dateTimeForEvent(CarbonImmutable $date, string $time): CarbonImmutable
    {
        [$hour, $minute] = array_pad(explode(':', $time), 2, '0');
        return $date->setTime((int) $hour, (int) $minute);
    }

    protected function timeSortKey(ScheduleEvent $event): string
    {
        return sprintf('%s-%s', $event->event_date?->format('Y-m-d') ?: '0000-00-00', $event->start_time ?: '00:00:00');
    }

    protected function actionItem(
        string $id,
        string $type,
        string $priority,
        string $title,
        string $description,
        string $cta,
        string $route,
        array $routeMeta,
    ): array {
        return [
            'id' => $id,
            'type' => $type,
            'priority' => $priority,
            'title' => $title,
            'description' => $description,
            'cta' => $cta,
            'route' => $route,
            'route_meta' => ['route' => $route, ...$routeMeta],
        ];
    }

    protected function activityItem(
        string $id,
        string $type,
        ?string $subjectName,
        ?string $groupName,
        ?string $authorName,
        string $content,
        ?string $timestamp,
    ): array {
        return [
            'id' => $id,
            'activity_type' => $type,
            'subject_name' => $subjectName,
            'group_name' => $groupName,
            'author_name' => $authorName,
            'content' => $content,
            'timestamp' => $timestamp,
            'route' => '/workspace/subjects',
        ];
    }
}
