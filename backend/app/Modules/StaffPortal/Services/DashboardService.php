<?php

namespace App\Modules\StaffPortal\Services;

use App\Core\Enums\UserRole;
use App\Core\Enums\WeekPattern;
use App\Core\Exceptions\ApiException;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Academic\Models\Subject;
use App\Modules\Content\Models\Lecture;
use App\Modules\Enrollment\Models\Enrollment;
use App\Modules\Grades\Models\GradeItem;
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
    protected const NOTIFICATIONS_PREVIEW_LIMIT = 5;

    protected const ACTIVITY_PREVIEW_LIMIT = 5;

    protected const SUBJECTS_PREVIEW_LIMIT = 4;

    protected const ACTION_CENTER_LIMIT = 8;

    protected const ATTENTION_LIMIT = 6;

    protected const PENDING_GRADING_LIMIT = 5;

    protected const RISK_ALERT_LIMIT = 5;

    protected const SUGGESTIONS_LIMIT = 5;

    public function dashboard(User $user): array
    {
        $this->ensureStaffRole($user);

        $permissionHash = md5(implode('|', [
            ...$user->effectivePermissions(),
            'grades:'.($user->canManageGrades() ? '1' : '0'),
            'content:'.($user->canManageContent() ? '1' : '0'),
            'schedule:'.($user->canManageSchedule() ? '1' : '0'),
        ]));

        return Cache::remember(
            sprintf('staff-dashboard:%d:%s:%s', $user->id, $user->role?->value ?? 'unknown', $permissionHash),
            now()->addSeconds(45),
            fn () => $this->buildDashboard($user),
        );
    }

    protected function buildDashboard(User $user): array
    {
        $today = CarbonImmutable::now();
        $tomorrow = $today->addDay();
        $weekEnd = $today->endOfWeek();
        $canManageGrades = $user->canManageGrades();
        $managedOfferings = $this->managedOfferings($user);
        $offeringIds = $managedOfferings->pluck('id')->filter()->values();
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

        $notificationsBaseQuery = UserNotification::query()
            ->where(function ($query) use ($user) {
                $query->where('target_user_id', $user->id)
                    ->orWhere('is_global', true);
            });

        $notificationUnreadCount = (clone $notificationsBaseQuery)
            ->where('is_read', false)
            ->count();

        $notifications = (clone $notificationsBaseQuery)
            ->latest()
            ->limit(10)
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

        $gradeItems = $canManageGrades
            ? GradeItem::query()
                ->with(['courseOffering.subject', 'student'])
                ->whereIn('course_offering_id', $offeringIds)
                ->get()
            : new EloquentCollection();

        $todaySchedule = $scheduleEvents
            ->filter(fn (ScheduleEvent $event) => $this->eventMatchesDate($event, $today))
            ->sortBy(fn (ScheduleEvent $event) => $this->timeSortKey($event))
            ->values();
        $todayStats = $this->buildTodayStats($todaySchedule, $quizzes, $tasks, $today);
        $todayScheduleItems = $this->buildTodaySchedule($todaySchedule, $today);
        $upcomingItems = $this->buildUpcoming($scheduleEvents, $tasks, $today);

        $missingSubmissionsByTask = $this->missingSubmissionsByTask(
            $tasks,
            $taskSubmissions,
            $enrollments,
        );
        $missingSubmissionsByStudent = $this->missingSubmissionsByStudent(
            $tasks,
            $taskSubmissions,
            $enrollments,
        );

        $studentInsights = $this->buildStudentInsights(
            $user,
            $enrollments,
            $posts,
            $comments,
            $messages,
            $missingSubmissionsByStudent,
            $today,
        );

        $pendingGradingByTask = $taskSubmissions
            ->filter(fn (TaskSubmission $submission) => $submission->submitted_at !== null && $submission->graded_at === null)
            ->groupBy('task_id');

        $subjectHealth = $this->subjectHealthScores(
            $subjects,
            $scheduleEvents,
            $lectures,
            $sectionContents,
            $quizzes,
            $tasks,
            $missingSubmissionsByTask,
            $pendingGradingByTask,
            $posts,
            $comments,
            $messages,
            $today,
        );

        $actionCenterItems = $this->buildActionRequired(
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
        );

        $studentsAttention = $this->buildStudentsAttention(
            $studentInsights['items'],
            $subjectIds,
        );
        $pendingGrading = $this->buildPendingGrading(
            $tasks,
            $pendingGradingByTask,
            $canManageGrades,
        );
        $performanceAnalytics = $this->buildPerformanceAnalytics($gradeItems, $canManageGrades);
        $courseHealth = $this->buildCourseHealth($subjectHealth, $performanceAnalytics);
        $subjectsOverview = $this->buildSubjectsOverview(
            $subjects,
            $managedOfferings,
            $enrollments,
            $subjectHealth,
            $user,
        );
        $subjectsPreview = $this->buildSubjectsPreview($subjects, $managedOfferings, $enrollments);
        $groupActivityItems = $this->buildGroupActivity($posts, $comments, $messages);
        $riskAlerts = $this->buildRiskAlerts(
            $actionCenterItems,
            $studentInsights['items'],
            $subjectHealth,
            $performanceAnalytics,
        );
        $notificationsPreview = $this->buildNotifications($notifications, $notificationUnreadCount);
        $weeklySummary = $this->buildWeeklySummary(
            $scheduleEvents,
            $quizzes,
            $tasks,
            $posts,
            $comments,
            $today,
            $weekEnd,
        );
        $smartSuggestions = $this->buildSmartSuggestions(
            $actionCenterItems,
            $riskAlerts,
            $courseHealth,
            $pendingGrading,
            $studentInsights,
            $user,
            $performanceAnalytics,
        );

        return [
            'header' => [
                'user' => $this->buildUserSummary($user, $subjects, $today),
                'notification_badge' => $notificationUnreadCount,
                'generated_at' => $today->toIso8601String(),
            ],
            'quick_actions' => $this->buildQuickActions($user, $subjects),
            'action_center' => [
                'summary' => $this->actionCenterSummary($actionCenterItems),
                'items' => $actionCenterItems,
            ],
            'today_focus' => $this->buildTodayFocus(
                $todaySchedule,
                $actionCenterItems,
                $pendingGrading,
                $notificationUnreadCount,
            ),
            'timeline' => $this->buildTimeline(
                $scheduleEvents,
                $quizzes,
                $tasks,
                $today,
                $tomorrow,
                $weekEnd,
            ),
            'subjects_overview' => $subjectsOverview,
            'students_attention' => $studentsAttention,
            'student_activity_insights' => $studentInsights,
            'course_health' => $courseHealth,
            'group_activity_feed' => [
                'items' => $groupActivityItems,
            ],
            'notifications_preview' => $notificationsPreview,
            'pending_grading' => $pendingGrading,
            'performance_analytics' => $performanceAnalytics,
            'risk_alerts' => $riskAlerts,
            'weekly_summary' => $weeklySummary,
            'smart_suggestions' => $smartSuggestions,
            'user' => $this->buildUserSummary($user, $subjects, $today),
            'notifications' => [
                'unread_count' => $notificationsPreview['unread_count'] ?? 0,
                'latest' => $notificationsPreview['items'] ?? [],
            ],
            'today_stats' => $todayStats,
            'action_required' => $actionCenterItems,
            'today_schedule' => $todayScheduleItems,
            'upcoming' => $upcomingItems,
            'subjects_preview' => $subjectsPreview,
            'group_activity' => $groupActivityItems,
            'student_insights' => [
                ...$studentInsights,
                'students_needing_attention' => count($studentInsights['items'] ?? []),
                'needs_attention' => $studentInsights['items'] ?? [],
            ],
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

    protected function buildQuickActions(User $user, Collection $subjects): array
    {
        $announcementRoute = $subjects->isNotEmpty()
            ? $this->subjectWorkspaceRoute((int) $subjects->first()->id)
            : '/workspace/subjects';

        $actions = [
            ['id' => 'add_lecture', 'label' => 'Add Lecture', 'description' => 'Publish lecture content before the next session.', 'route' => '/workspace/lectures', 'permission' => 'lectures.create', 'icon' => 'lecture', 'tone' => 'primary'],
            ['id' => 'add_section', 'label' => 'Add Section', 'description' => 'Upload section or lab content for assistants.', 'route' => '/workspace/sections', 'permission' => 'section_content.create', 'icon' => 'section', 'tone' => 'secondary'],
            ['id' => 'add_quiz', 'label' => 'Add Quiz', 'description' => 'Create or publish an assessment window.', 'route' => '/workspace/quizzes', 'permission' => 'quizzes.create', 'icon' => 'quiz', 'tone' => 'warning'],
            ['id' => 'add_task', 'label' => 'Add Task', 'description' => 'Create a student task with a due date.', 'route' => '/workspace/tasks', 'permission' => 'tasks.create', 'icon' => 'task', 'tone' => 'success'],
            ['id' => 'send_announcement', 'label' => 'Send Announcement', 'description' => 'Open the subject workspace and post an update.', 'route' => $announcementRoute, 'permission' => 'community.post', 'icon' => 'announcement', 'tone' => 'danger'],
        ];

        return collect($actions)
            ->filter(fn (array $action) => $user->hasPermission($action['permission']) && ($action['id'] !== 'send_announcement' || $subjects->isNotEmpty()))
            ->values()
            ->all();
    }

    protected function buildNotifications(EloquentCollection $notifications, int $unreadCount): array
    {
        return [
            'unread_count' => $unreadCount,
            'items' => $notifications->take(self::NOTIFICATIONS_PREVIEW_LIMIT)->map(fn (UserNotification $notification) => [
                'id' => $notification->id,
                'title' => $notification->title,
                'body' => $notification->body,
                'time' => optional($notification->created_at)->toIso8601String(),
                'is_unread' => ! $notification->is_read,
                'category' => $notification->category ?: (string) ($notification->type?->value ?? $notification->type ?? 'SYSTEM'),
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
        $canCreateLectures = $user->hasPermission('lectures.create');
        $canCreateSectionContent = $user->hasPermission('section_content.create');
        $canManageQuizzes = $user->hasPermission('quizzes.create');
        $canViewTasks = $user->hasPermission('tasks.view');
        $canManageTasks = $user->hasPermission('tasks.create');
        $canManageGrades = $user->canManageGrades();

        foreach ($scheduleEvents as $event) {
            $startAt = $this->nextOccurrence($event, $today);
            if ($startAt === null || $startAt->greaterThan($windowEnd)) {
                continue;
            }

            $eventType = strtoupper((string) ($event->event_type ?: $event->type?->value ?: $event->type));
            $subjectId = (int) ($event->subject_id ?: $event->courseOffering?->subject_id);
            $subjectName = $event->courseOffering?->subject?->name ?: $subjects->firstWhere('id', $subjectId)?->name;

            if ($eventType === 'LECTURE' && $user->role === UserRole::DOCTOR && $canCreateLectures) {
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

            if ($eventType === 'SECTION' && $user->role === UserRole::TA && $canCreateSectionContent) {
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
            if (! $canManageQuizzes) {
                continue;
            }

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
            if (! $task->is_published && $canManageTasks) {
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
            } elseif ($task->due_date !== null && $task->due_date->between($today->startOfDay(), $today->addDays(3)->endOfDay()) && $canViewTasks) {
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

        if ($canManageGrades) {
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
        }

        if ($canViewTasks) {
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
        }

        $priorityOrder = ['HIGH' => 0, 'MEDIUM' => 1, 'LOW' => 2];

        return $items
            ->unique('id')
            ->sortBy(fn (array $item) => $priorityOrder[$item['priority']] ?? 9)
            ->take(self::ACTION_CENTER_LIMIT)
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
        return $subjects->take(self::SUBJECTS_PREVIEW_LIMIT)->map(function (Subject $subject) use ($managedOfferings, $enrollments) {
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
            ->take(self::ACTIVITY_PREVIEW_LIMIT)
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
                $severity = 'LOW';
                $missingCount = (int) ($missingSubmissionsByStudent[$student->id] ?? 0);
                if ($missingCount > 0) {
                    $reasons[] = sprintf('Missed %d task submissions', $missingCount);
                    $severity = $missingCount >= 2 ? 'HIGH' : 'MEDIUM';
                }
                if ($student->last_login_at === null || $student->last_login_at->lessThan($today->subDays(10))) {
                    $days = $student->last_login_at?->diffInDays($today) ?? 999;
                    $reasons[] = sprintf('No login in %d days', $days);
                    if ($days >= 14) {
                        $severity = 'HIGH';
                    } elseif ($severity === 'LOW') {
                        $severity = 'MEDIUM';
                    }
                }
                if (($recentActivity[$student->id] ?? 0) === 0) {
                    $reasons[] = 'Low group engagement this week';
                    if ($severity === 'LOW') {
                        $severity = 'MEDIUM';
                    }
                }

                if ($reasons === []) {
                    return null;
                }

                return [
                    'student_id' => $student->id,
                    'name' => $student->full_name ?: $student->username,
                    'reason' => $reasons[0],
                    'details' => $reasons,
                    'severity' => $severity,
                    'last_seen' => $student->last_login_at?->toIso8601String(),
                ];
            })
            ->filter()
            ->take(self::ATTENTION_LIMIT)
            ->values();

        $reference = $staffUser->last_login_at ?? $today->subDay();
        $unreadMessages = $messages
            ->filter(fn (Message $message) => $message->created_at?->greaterThan($reference) && $message->sender_user_id !== $staffUser->id)
            ->count();
        $lowEngagementCount = $students->filter(fn (User $student) => ($recentActivity[$student->id] ?? 0) === 0)->count();
        $engagementRate = $students->isEmpty()
            ? 0
            : (int) round((($students->count() - $lowEngagementCount) / $students->count()) * 100);

        return [
            'summary' => sprintf('%d of %d students showed recent activity this week.', $students->count() - $inactiveStudents, $students->count()),
            'active_students' => $activeStudents,
            'inactive_students' => $inactiveStudents,
            'missing_submissions' => (int) $missingSubmissionsByStudent->sum(),
            'new_comments' => $comments->filter(fn (Comment $comment) => $comment->created_at?->greaterThanOrEqualTo($today->subDay()))->count(),
            'unread_messages' => $unreadMessages,
            'low_engagement_count' => $lowEngagementCount,
            'engagement_rate' => $engagementRate,
            'students_needing_attention' => $needsAttention->count(),
            'items' => $needsAttention->all(),
        ];
    }

    protected function actionCenterSummary(array $items): string
    {
        $high = collect($items)->where('priority', 'HIGH')->count();
        $medium = collect($items)->where('priority', 'MEDIUM')->count();

        if ($high === 0 && $medium === 0) {
            return 'No urgent blockers are open right now.';
        }

        return sprintf('%d high-priority and %d medium-priority decisions are ready for action.', $high, $medium);
    }

    protected function buildTodayFocus(
        Collection $todaySchedule,
        array $actionCenterItems,
        array $pendingGrading,
        int $notificationUnreadCount,
    ): array {
        $primaryAction = $actionCenterItems[0] ?? null;
        $sessionsToday = $todaySchedule->count();
        $gradingCount = (int) ($pendingGrading['count'] ?? 0);
        $highPriorityCount = collect($actionCenterItems)->where('priority', 'HIGH')->count();

        $headline = match (true) {
            $highPriorityCount > 0 => sprintf('%d urgent items need attention first.', $highPriorityCount),
            $sessionsToday > 0 => sprintf('%d teaching blocks are on today.', $sessionsToday),
            $gradingCount > 0 => sprintf('%d submissions are waiting for grading.', $gradingCount),
            default => 'Your workspace is under control today.',
        };

        $summary = match (true) {
            $primaryAction !== null => $primaryAction['explanation'],
            $notificationUnreadCount > 0 => sprintf('You still have %d unread notifications to clear.', $notificationUnreadCount),
            default => 'Use the quick actions and smart suggestions to stay ahead of the week.',
        };

        return [
            'headline' => $headline,
            'summary' => $summary,
            'primary_action' => $primaryAction,
            'metrics' => [
                ['label' => 'Sessions today', 'value' => $sessionsToday, 'tone' => 'primary'],
                ['label' => 'Urgent actions', 'value' => $highPriorityCount, 'tone' => $highPriorityCount > 0 ? 'danger' : 'success'],
                ['label' => 'Pending grading', 'value' => $gradingCount, 'tone' => $gradingCount > 0 ? 'warning' : 'success'],
                ['label' => 'Unread notifications', 'value' => $notificationUnreadCount, 'tone' => $notificationUnreadCount > 0 ? 'secondary' : 'success'],
            ],
        ];
    }

    protected function buildTimeline(
        Collection $scheduleEvents,
        EloquentCollection $quizzes,
        EloquentCollection $tasks,
        CarbonImmutable $today,
        CarbonImmutable $tomorrow,
        CarbonImmutable $weekEnd,
    ): array {
        $timelineItems = collect();

        foreach ($scheduleEvents as $event) {
            $when = $this->nextOccurrence($event, $today);
            if ($when === null || $when->greaterThan($weekEnd->endOfDay())) {
                continue;
            }

            $timelineItems->push([
                'id' => 'schedule_'.$event->id,
                'bucket' => $this->timelineBucket($when, $today, $tomorrow),
                'type' => strtoupper((string) ($event->event_type ?: $event->type?->value ?: $event->type)),
                'title' => $event->title ?: ($event->courseOffering?->subject?->name ?: $event->subject?->name ?: 'Session'),
                'subject_name' => $event->courseOffering?->subject?->name ?: $event->subject?->name,
                'when_label' => $when->format('D, g:i A'),
                'status' => $event->location ? 'Room' : 'Online',
                'route' => '/workspace/schedule',
            ]);
        }

        foreach ($quizzes as $quiz) {
            if ($quiz->quiz_date === null || $quiz->quiz_date->greaterThan($weekEnd->endOfDay())) {
                continue;
            }

            $timelineItems->push([
                'id' => 'quiz_'.$quiz->id,
                'bucket' => $this->timelineBucket($quiz->quiz_date->toImmutable(), $today, $tomorrow),
                'type' => 'QUIZ',
                'title' => $quiz->title,
                'subject_name' => $quiz->subject?->name,
                'when_label' => $quiz->quiz_date->format('D, M j'),
                'status' => $quiz->is_published ? 'Published' : 'Draft',
                'route' => '/workspace/quizzes',
            ]);
        }

        foreach ($tasks as $task) {
            if ($task->due_date === null || $task->due_date->greaterThan($weekEnd->endOfDay())) {
                continue;
            }

            $timelineItems->push([
                'id' => 'task_'.$task->id,
                'bucket' => $this->timelineBucket($task->due_date->toImmutable(), $today, $tomorrow),
                'type' => 'TASK',
                'title' => $task->title,
                'subject_name' => $task->subject?->name,
                'when_label' => $task->due_date->format('D, M j'),
                'status' => $task->is_published ? 'Open' : 'Draft',
                'route' => '/workspace/tasks',
            ]);
        }

        return [
            'groups' => [
                [
                    'id' => 'today',
                    'label' => 'Today',
                    'items' => $timelineItems->where('bucket', 'today')->values()->all(),
                ],
                [
                    'id' => 'tomorrow',
                    'label' => 'Tomorrow',
                    'items' => $timelineItems->where('bucket', 'tomorrow')->values()->all(),
                ],
                [
                    'id' => 'this_week',
                    'label' => 'This Week',
                    'items' => $timelineItems->where('bucket', 'this_week')->values()->all(),
                ],
            ],
        ];
    }

    protected function timelineBucket(CarbonImmutable $when, CarbonImmutable $today, CarbonImmutable $tomorrow): string
    {
        if ($when->isSameDay($today)) {
            return 'today';
        }

        if ($when->isSameDay($tomorrow)) {
            return 'tomorrow';
        }

        return 'this_week';
    }

    protected function buildSubjectsOverview(
        Collection $subjects,
        EloquentCollection $managedOfferings,
        EloquentCollection $enrollments,
        Collection $subjectHealth,
        User $user,
    ): array {
        return [
            'summary' => sprintf('%d active subjects are assigned to this workspace.', $subjects->count()),
            'items' => $subjects->take(4)->map(function (Subject $subject) use ($managedOfferings, $enrollments, $subjectHealth, $user) {
                $subjectOfferings = $managedOfferings->where('subject_id', $subject->id);
                $studentCount = $subjectOfferings->sum(
                    fn (CourseOffering $offering) => $enrollments->where('course_offering_id', $offering->id)->count(),
                );
                $health = $subjectHealth->get($subject->id, ['score' => 88, 'status' => 'HEALTHY']);

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
                    'health_score' => $health['score'],
                    'risk_level' => $health['status'],
                    'quick_actions' => $this->subjectQuickActions($user, (int) $subject->id),
                ];
            })->values()->all(),
        ];
    }

    protected function subjectQuickActions(User $user, int $subjectId): array
    {
        $actions = [
            ['label' => 'Open Subject', 'route' => $this->subjectWorkspaceRoute($subjectId)],
            ['label' => 'Send Announcement', 'route' => $this->subjectWorkspaceRoute($subjectId)],
        ];

        if ($user->hasPermission('lectures.create')) {
            $actions[] = ['label' => 'Add Lecture', 'route' => '/workspace/lectures'];
        }

        if ($user->hasPermission('section_content.create')) {
            $actions[] = ['label' => 'Add Section', 'route' => '/workspace/sections'];
        }

        if ($user->hasPermission('quizzes.create')) {
            $actions[] = ['label' => 'Add Quiz', 'route' => '/workspace/quizzes'];
        }

        return $actions;
    }

    protected function buildStudentsAttention(array $items, Collection $subjectIds): array
    {
        $subjectId = (int) ($subjectIds->first() ?? 0);

        return [
            'count' => count($items),
            'items' => collect($items)->take(6)->map(fn (array $item) => [
                ...$item,
                'cta_label' => 'Review',
                'route' => $subjectId > 0 ? $this->subjectWorkspaceRoute($subjectId) : '/workspace/subjects',
            ])->values()->all(),
        ];
    }

    protected function subjectHealthScores(
        Collection $subjects,
        Collection $scheduleEvents,
        EloquentCollection $lectures,
        EloquentCollection $sectionContents,
        EloquentCollection $quizzes,
        EloquentCollection $tasks,
        Collection $missingSubmissionsByTask,
        Collection $pendingGradingByTask,
        EloquentCollection $posts,
        EloquentCollection $comments,
        EloquentCollection $messages,
        CarbonImmutable $today,
    ): Collection {
        return $subjects->mapWithKeys(function (Subject $subject) use (
            $scheduleEvents,
            $lectures,
            $sectionContents,
            $quizzes,
            $tasks,
            $missingSubmissionsByTask,
            $pendingGradingByTask,
            $posts,
            $comments,
            $messages,
            $today,
        ) {
            $score = 100;

            $subjectEvents = $scheduleEvents->filter(function (ScheduleEvent $event) use ($subject, $today) {
                $subjectId = (int) ($event->subject_id ?: $event->courseOffering?->subject_id);
                $next = $this->nextOccurrence($event, $today);

                return $subjectId === $subject->id
                    && $next !== null
                    && $next->between($today->startOfDay(), $today->addDays(7)->endOfDay());
            });

            $recentLecture = $lectures
                ->where('subject_id', $subject->id)
                ->first(fn (Lecture $lecture) => $lecture->is_published && $lecture->published_at?->greaterThanOrEqualTo($today->subDays(14)));
            if ($subjectEvents->contains(fn (ScheduleEvent $event) => strtoupper((string) ($event->event_type ?: $event->type?->value ?: $event->type)) === 'LECTURE') && ! $recentLecture) {
                $score -= 20;
            }

            $recentSection = $sectionContents
                ->where('subject_id', $subject->id)
                ->first(fn (AcademicSectionContent $content) => $content->is_published && $content->published_at?->greaterThanOrEqualTo($today->subDays(14)));
            if ($subjectEvents->contains(fn (ScheduleEvent $event) => strtoupper((string) ($event->event_type ?: $event->type?->value ?: $event->type)) === 'SECTION') && ! $recentSection) {
                $score -= 15;
            }

            $draftQuizCount = $quizzes
                ->where('subject_id', $subject->id)
                ->filter(fn (Quiz $quiz) => ! $quiz->is_published && $quiz->quiz_date !== null && $quiz->quiz_date->between($today->startOfDay(), $today->addDays(7)->endOfDay()))
                ->count();
            if ($draftQuizCount > 0) {
                $score -= min(20, $draftQuizCount * 8);
            }

            $subjectTaskIds = $tasks->where('subject_id', $subject->id)->pluck('id')->map(fn ($id) => (int) $id);
            $missingCount = $missingSubmissionsByTask->only($subjectTaskIds->all())->sum();
            if ($missingCount > 0) {
                $score -= min(25, $missingCount * 4);
            }

            $pendingGradingCount = $pendingGradingByTask
                ->only($subjectTaskIds->all())
                ->sum(fn (Collection $items) => $items->count());
            if ($pendingGradingCount > 0) {
                $score -= min(20, $pendingGradingCount * 3);
            }

            $recentSignals = $posts->filter(fn (Post $post) => $post->group?->courseOffering?->subject_id === $subject->id)->count()
                + $comments->filter(fn (Comment $comment) => $comment->post?->group?->courseOffering?->subject_id === $subject->id)->count()
                + $messages->filter(fn (Message $message) => $message->group?->courseOffering?->subject_id === $subject->id)->count();
            if ($recentSignals === 0) {
                $score -= 10;
            }

            $score = max(36, min(100, $score));

            return [
                $subject->id => [
                    'score' => $score,
                    'status' => $this->healthStatus($score),
                    'name' => $subject->name,
                ],
            ];
        });
    }

    protected function healthStatus(int $score): string
    {
        return match (true) {
            $score >= 85 => 'HEALTHY',
            $score >= 70 => 'WATCH',
            default => 'AT_RISK',
        };
    }

    protected function buildCourseHealth(Collection $subjectHealth, array $performanceAnalytics): array
    {
        $scores = $subjectHealth->pluck('score');
        $overall = $scores->isEmpty() ? 92 : (int) round($scores->avg());
        $averageScore = $performanceAnalytics['average_score'] ?? null;
        $metrics = collect([
            ['label' => 'Healthy subjects', 'value' => $subjectHealth->where('status', 'HEALTHY')->count(), 'tone' => 'success'],
            ['label' => 'Watchlist', 'value' => $subjectHealth->where('status', 'WATCH')->count(), 'tone' => 'warning'],
            ['label' => 'At risk', 'value' => $subjectHealth->where('status', 'AT_RISK')->count(), 'tone' => 'danger'],
        ]);

        if ($averageScore !== null) {
            $metrics->push([
                'label' => 'Average grade',
                'value' => sprintf('%s%%', $averageScore),
                'tone' => $averageScore >= 70 ? 'success' : 'warning',
            ]);
        }

        return [
            'overall_score' => $overall,
            'status' => $this->healthStatus($overall),
            'summary' => $subjectHealth->where('status', 'AT_RISK')->isNotEmpty()
                ? sprintf('%d subject areas need intervention this week.', $subjectHealth->where('status', 'AT_RISK')->count())
                : 'Course delivery and student follow-up are trending well.',
            'metrics' => $metrics->all(),
            'subjects' => $subjectHealth
                ->sortBy('score')
                ->take(self::SUBJECTS_PREVIEW_LIMIT)
                ->map(fn (array $item, int $subjectId) => [
                    'subject_id' => $subjectId,
                    'subject_name' => $item['name'],
                    'score' => $item['score'],
                    'status' => $item['status'],
                ])
                ->values()
                ->all(),
        ];
    }

    protected function buildPendingGrading(
        EloquentCollection $tasks,
        Collection $pendingGradingByTask,
        bool $canManageGrades,
    ): array {
        if (! $canManageGrades) {
            return [
                'can_manage' => false,
                'count' => 0,
                'summary' => 'Grading insights are hidden for this role.',
                'items' => [],
            ];
        }

        $items = $pendingGradingByTask
            ->map(function (Collection $submissions, $taskId) use ($tasks) {
                $task = $tasks->firstWhere('id', (int) $taskId);
                if (! $task) {
                    return null;
                }

                return [
                    'task_id' => $task->id,
                    'title' => $task->title,
                    'subject_name' => $task->subject?->name,
                    'pending_count' => $submissions->count(),
                    'cta_label' => 'Grade',
                    'route' => '/workspace/tasks',
                ];
            })
            ->filter()
            ->sortByDesc('pending_count')
            ->take(self::PENDING_GRADING_LIMIT)
            ->values();

        return [
            'can_manage' => true,
            'count' => (int) $items->sum('pending_count'),
            'summary' => $items->isEmpty()
                ? 'No grading backlog is waiting right now.'
                : sprintf('%d submissions are waiting across %d tasks.', $items->sum('pending_count'), $items->count()),
            'items' => $items->all(),
        ];
    }

    protected function buildPerformanceAnalytics(EloquentCollection $gradeItems, bool $canManageGrades): array
    {
        if (! $canManageGrades || $gradeItems->isEmpty()) {
            return [
                'is_limited' => ! $canManageGrades,
                'summary' => $canManageGrades
                    ? 'Performance analytics will appear when graded records exist.'
                    : 'Performance analytics are hidden for this role.',
                'average_score' => null,
                'trend' => [],
                'top_performers' => [],
                'low_performers' => [],
            ];
        }

        $normalized = $gradeItems
            ->filter(fn (GradeItem $item) => (float) $item->max_score > 0)
            ->map(fn (GradeItem $item) => [
                'student_id' => $item->student_user_id,
                'student_name' => $item->student?->full_name ?: $item->student?->username,
                'subject_name' => $item->courseOffering?->subject?->name,
                'percentage' => round((((float) $item->score) / ((float) $item->max_score)) * 100, 1),
            ]);

        $byStudent = $normalized
            ->groupBy('student_id')
            ->map(fn (Collection $items) => [
                'student_name' => $items->first()['student_name'],
                'average_score' => round($items->avg('percentage'), 1),
            ]);

        return [
            'is_limited' => false,
            'summary' => sprintf('Average graded performance is %s%% across %d grade records.', round($normalized->avg('percentage'), 1), $normalized->count()),
            'average_score' => round($normalized->avg('percentage'), 1),
            'trend' => $normalized->groupBy('subject_name')->map(fn (Collection $items, string $subjectName) => [
                'label' => $subjectName,
                'value' => round($items->avg('percentage'), 1),
            ])->values()->take(5)->all(),
            'top_performers' => $byStudent->sortByDesc('average_score')->take(3)->values()->all(),
            'low_performers' => $byStudent->sortBy('average_score')->take(3)->values()->all(),
        ];
    }

    protected function buildRiskAlerts(
        array $actionCenterItems,
        array $studentsAttention,
        Collection $subjectHealth,
        array $performanceAnalytics,
    ): array
    {
        $alerts = collect();

        foreach ($actionCenterItems as $item) {
            if ($item['priority'] !== 'HIGH') {
                continue;
            }

            $alerts->push([
                'id' => 'action_'.$item['id'],
                'severity' => 'HIGH',
                'title' => $item['title'],
                'explanation' => $item['explanation'],
                'cta_label' => $item['cta_label'],
                'route' => $item['route'],
            ]);
        }

        foreach ($studentsAttention as $student) {
            if (($student['severity'] ?? 'LOW') === 'LOW') {
                continue;
            }

            $alerts->push([
                'id' => 'student_'.$student['student_id'],
                'severity' => $student['severity'],
                'title' => sprintf('%s needs follow-up', $student['name']),
                'explanation' => $student['reason'],
                'cta_label' => 'Review',
                'route' => '/workspace/subjects',
            ]);
        }

        foreach ($subjectHealth->where('status', 'AT_RISK') as $subjectId => $health) {
            $alerts->push([
                'id' => 'health_'.$subjectId,
                'severity' => 'HIGH',
                'title' => sprintf('%s is at risk', $health['name']),
                'explanation' => sprintf('Health score dropped to %d.', $health['score']),
                'cta_label' => 'Open Subject',
                'route' => $this->subjectWorkspaceRoute((int) $subjectId),
            ]);
        }

        $averageScore = $performanceAnalytics['average_score'] ?? null;
        if ($averageScore !== null && $averageScore < 65) {
            $alerts->push([
                'id' => 'performance_average_low',
                'severity' => 'HIGH',
                'title' => 'Average grade trend is below target',
                'explanation' => sprintf('Recent graded work is averaging %s%%, which signals a widening performance gap.', $averageScore),
                'cta_label' => 'Review analytics',
                'route' => '/workspace/tasks',
            ]);
        }

        return [
            'count' => $alerts->count(),
            'items' => $alerts->unique('id')->take(self::RISK_ALERT_LIMIT)->values()->all(),
        ];
    }

    protected function buildWeeklySummary(
        Collection $scheduleEvents,
        EloquentCollection $quizzes,
        EloquentCollection $tasks,
        EloquentCollection $posts,
        EloquentCollection $comments,
        CarbonImmutable $today,
        CarbonImmutable $weekEnd,
    ): array {
        $weekEvents = $scheduleEvents
            ->map(fn (ScheduleEvent $event) => ['event' => $event, 'when' => $this->nextOccurrence($event, $today)])
            ->filter(fn (array $payload) => $payload['when'] !== null && $payload['when']->between($today->startOfDay(), $weekEnd->endOfDay()));

        return [
            'headline' => sprintf(
                '%d sessions, %d quizzes, and %d task deadlines are scheduled this week.',
                $weekEvents->count(),
                $quizzes->filter(fn (Quiz $quiz) => $quiz->quiz_date !== null && $quiz->quiz_date->between($today->startOfDay(), $weekEnd->endOfDay()))->count(),
                $tasks->filter(fn (Task $task) => $task->due_date !== null && $task->due_date->between($today->startOfDay(), $weekEnd->endOfDay()))->count(),
            ),
            'items' => [
                ['label' => 'Sessions', 'value' => $weekEvents->count(), 'caption' => 'Lectures and sections on the timetable'],
                ['label' => 'Assessments', 'value' => $quizzes->filter(fn (Quiz $quiz) => $quiz->quiz_date !== null && $quiz->quiz_date->between($today->startOfDay(), $weekEnd->endOfDay()))->count(), 'caption' => 'Quizzes scheduled this week'],
                ['label' => 'Deadlines', 'value' => $tasks->filter(fn (Task $task) => $task->due_date !== null && $task->due_date->between($today->startOfDay(), $weekEnd->endOfDay()))->count(), 'caption' => 'Task due dates coming up'],
                ['label' => 'Discussion signals', 'value' => $posts->count() + $comments->count(), 'caption' => 'Recent group posts and comments'],
            ],
        ];
    }

    protected function buildSmartSuggestions(
        array $actionCenterItems,
        array $riskAlerts,
        array $courseHealth,
        array $pendingGrading,
        array $studentInsights,
        User $user,
        array $performanceAnalytics,
    ): array {
        $items = collect();

        if (($pendingGrading['count'] ?? 0) > 0 && $user->canManageGrades()) {
            $items->push([
                'id' => 'grading_sprint',
                'title' => 'Run a grading sprint today',
                'explanation' => 'Clearing the grading queue first will improve feedback speed and reduce hidden risk.',
                'cta_label' => 'Open grading queue',
                'route' => '/workspace/tasks',
            ]);
        }

        if (($studentInsights['low_engagement_count'] ?? 0) > 0) {
            $items->push([
                'id' => 'engagement_followup',
                'title' => 'Post a group reminder',
                'explanation' => 'Low activity students are increasing. A short clarification or reminder could improve participation quickly.',
                'cta_label' => 'Send announcement',
                'route' => '/workspace/subjects',
            ]);
        }

        if (($courseHealth['overall_score'] ?? 100) < 80) {
            $items->push([
                'id' => 'health_recovery',
                'title' => 'Stabilize the weakest subject first',
                'explanation' => 'One or more subjects are trending toward risk. Resolve missing content and deadlines before expanding new work.',
                'cta_label' => 'Review subjects',
                'route' => '/workspace/subjects',
            ]);
        }

        $averageScore = $performanceAnalytics['average_score'] ?? null;
        if ($averageScore !== null && $averageScore < 70 && $user->canManageGrades()) {
            $items->push([
                'id' => 'grade_recovery',
                'title' => 'Review low performers before the next session',
                'explanation' => 'Recent grade averages are soft. A quick pass on weak performers can help you intervene before the next deadline.',
                'cta_label' => 'Open analytics',
                'route' => '/workspace/tasks',
            ]);
        }

        if (($riskAlerts['count'] ?? 0) === 0 && count($actionCenterItems) <= 2) {
            $items->push([
                'id' => 'proactive_build',
                'title' => 'Prepare next week early',
                'explanation' => 'The board is relatively clear. This is a good window to draft the next lecture or quiz.',
                'cta_label' => 'Use quick actions',
                'route' => '/workspace/home',
            ]);
        }

        return [
            'items' => $items->take(self::SUGGESTIONS_LIMIT)->values()->all(),
        ];
    }

    protected function subjectWorkspaceRoute(int $subjectId): string
    {
        return sprintf('/workspace/subjects/%d', $subjectId);
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
            'explanation' => $description,
            'cta_label' => $cta,
            'route' => $route,
            'meta' => ['route' => $route, ...$routeMeta],
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
