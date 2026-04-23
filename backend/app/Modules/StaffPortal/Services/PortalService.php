<?php

namespace App\Modules\StaffPortal\Services;

use App\Core\Exceptions\ApiException;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Academic\Models\Subject;
use App\Modules\Content\Models\Attachment;
use App\Modules\Content\Models\Lecture;
use App\Modules\Enrollment\Models\Enrollment;
use App\Modules\Grades\Enums\GradeType;
use App\Modules\Grades\Models\GradeItem;
use App\Modules\Group\Models\Comment;
use App\Modules\Group\Models\GroupChat;
use App\Modules\Group\Models\Post;
use App\Modules\Notifications\Models\UserNotification;
use App\Modules\Schedule\Models\ScheduleEvent;
use App\Modules\Shared\Services\AuditLogService;
use App\Modules\StaffPortal\Models\AcademicSectionContent;
use App\Modules\StaffPortal\Models\Quiz;
use App\Modules\StaffPortal\Models\Task;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\Response;

class PortalService
{
    public function __construct(protected AuditLogService $auditLogService) {}

    public function profile(User $user): User
    {
        return $user->fresh(['roles.permissions', 'permissions']);
    }

    public function updateSettings(User $user, array $payload): User
    {
        $user->update([
            'language' => $payload['language'] ?? $user->language,
            'notification_enabled' => $payload['notification_enabled'] ?? $user->notification_enabled,
            'phone' => $payload['phone'] ?? $user->phone,
        ]);

        return $this->profile($user);
    }

    public function dashboard(User $user): array
    {
        $subjectIds = $this->assignedSubjectIds($user);
        $events = $this->schedule($user)->take(4);

        return [
            'metrics' => [
                ['label' => 'Assigned subjects', 'value' => (string) $subjectIds->count(), 'caption' => 'Live teaching load'],
                ['label' => 'Lectures', 'value' => (string) $this->lectures($user)->count(), 'caption' => 'Visible to students'],
                ['label' => 'Quizzes', 'value' => (string) $this->quizzes($user)->count(), 'caption' => 'Active assessments'],
                ['label' => 'Unread alerts', 'value' => (string) $this->notifications($user)->where('is_read', false)->count(), 'caption' => 'Needs attention'],
            ],
            'upcoming' => $events->map(fn ($event) => [
                'title' => $event->title,
                'subtitle' => trim(($event->event_date?->format('Y-m-d') ?? '').' '.($event->start_time ?? '')),
                'tag' => strtoupper((string) $event->event_type),
            ])->values(),
            'quick_actions' => $user->effectivePermissions(),
        ];
    }

    public function subjects(User $user): Collection
    {
        $subjectIds = $this->assignedSubjectIds($user);

        return Subject::query()
            ->with(['department', 'academicYear', 'sections.assistant', 'courseOfferings.doctor', 'courseOfferings.ta'])
            ->whereIn('id', $subjectIds)
            ->get();
    }

    public function subject(User $user, Subject $subject): Subject
    {
        abort_unless($this->assignedSubjectIds($user)->contains($subject->id) || $user->isAdmin(), Response::HTTP_FORBIDDEN, 'You are not assigned to this subject.');

        return $subject->load(['department', 'academicYear', 'sections.assistant', 'courseOfferings.doctor', 'courseOfferings.ta']);
    }

    public function subjectWorkspace(User $user, Subject $subject): array
    {
        $subject = $this->subject($user, $subject);

        return [
            'subject' => $this->subjectSummaryPayload($user, $subject),
            'lectures' => $this->lectures($user)->where('subject_id', $subject->id)->values()->map(fn (Lecture $lecture) => $this->lecturePayload($lecture))->all(),
            'sections' => $this->sectionContents($user)->where('subject_id', $subject->id)->values()->map(fn (AcademicSectionContent $section) => [
                'id' => $section->id,
                'subject_id' => $section->subject_id,
                'title' => $section->title,
                'week_number' => $section->week_number,
                'assistant_name' => $section->assistant_name,
                'video_url' => $section->video_url,
                'file_url' => $section->file_url,
                'is_published' => $section->is_published,
                'published_at' => optional($section->published_at)->toIso8601String(),
            ])->all(),
            'quizzes' => $this->quizzes($user)->where('subject_id', $subject->id)->values()->map(fn (Quiz $quiz) => [
                'id' => $quiz->id,
                'subject_id' => $quiz->subject_id,
                'title' => $quiz->title,
                'owner_name' => $quiz->owner_name,
                'quiz_type' => $quiz->quiz_type,
                'quiz_date' => (string) $quiz->quiz_date,
                'is_published' => $quiz->is_published,
                'quiz_link' => $quiz->quiz_link,
            ])->all(),
            'tasks' => $this->tasks($user)->where('subject_id', $subject->id)->values()->map(fn (Task $task) => [
                'id' => $task->id,
                'subject_id' => $task->subject_id,
                'title' => $task->title,
                'owner_name' => $task->owner_name,
                'lecture_or_section_name' => $task->lecture_or_section_name,
                'due_date' => (string) $task->due_date,
                'is_published' => $task->is_published,
            ])->all(),
            'group' => $this->subjectGroup($user, $subject),
            'results' => $this->subjectResults($user, $subject),
            'students' => $this->subjectStudents($user, $subject),
        ];
    }

    public function lectures(User $user): Collection
    {
        return Lecture::query()
            ->with(['subject', 'author'])
            ->whereIn('subject_id', $this->assignedSubjectIds($user))
            ->latest()
            ->get();
    }

    public function createLecture(User $user, array $payload): Lecture
    {
        $subjectId = $payload['subject_id'] ?? $this->resolveDefaultSubjectId($user);

        $lecture = Lecture::query()->create([
            'course_offering_id' => $this->resolveDefaultCourseOfferingId($user, (int) $subjectId),
            'subject_id' => $subjectId,
            'created_by' => $user->id,
            'title' => $payload['title'],
            'description' => $payload['description'] ?? null,
            'week_number' => $payload['week_number'] ?? 1,
            'instructor_name' => $payload['instructor_name'] ?? ($user->full_name ?: $user->username),
            'video_url' => $payload['video_url'] ?? null,
            'meeting_url' => $payload['meeting_url'] ?? null,
            'delivery_mode' => $payload['delivery_mode'] ?? 'in_person',
            'location_label' => $payload['location_label'] ?? null,
            'attachment_label' => $payload['attachment_label'] ?? null,
            'starts_at' => $this->startsAtFromPayload($payload),
            'ends_at' => $this->endsAtFromPayload($payload),
            'is_published' => ($payload['publish_now'] ?? false) && ! ($payload['save_as_draft'] ?? false),
            'published_at' => ($payload['publish_now'] ?? false) && ! ($payload['save_as_draft'] ?? false) ? now() : null,
        ]);

        $this->auditLogService->log($user, 'staff-portal.lecture.create', $lecture, [], request());

        return $lecture->fresh(['subject', 'author']);
    }

    public function publishLecture(User $user, Lecture $lecture): Lecture
    {
        abort_unless($lecture->created_by === $user->id || $user->isAdmin(), Response::HTTP_FORBIDDEN, 'You cannot publish this lecture.');

        $lecture->update([
            'is_published' => true,
            'published_at' => now(),
        ]);

        $this->auditLogService->log($user, 'staff-portal.lecture.publish', $lecture, [], request());

        return $lecture->fresh(['subject', 'author']);
    }

    public function deleteLecture(User $user, Lecture $lecture): void
    {
        abort_unless($lecture->created_by === $user->id || $user->isAdmin(), Response::HTTP_FORBIDDEN, 'You cannot delete this lecture.');

        $lecture->delete();
    }

    public function sectionContents(User $user): Collection
    {
        return AcademicSectionContent::query()
            ->whereIn('subject_id', $this->assignedSubjectIds($user))
            ->latest()
            ->get();
    }

    public function createSectionContent(User $user, array $payload): AcademicSectionContent
    {
        return AcademicSectionContent::query()->create([
            'subject_id' => $payload['subject_id'] ?? $this->resolveDefaultSubjectId($user),
            'created_by' => $user->id,
            'title' => $payload['title'],
            'week_number' => $payload['week_number'] ?? 1,
            'assistant_name' => $payload['assistant_name'] ?? ($user->full_name ?: $user->username),
            'video_url' => $payload['video_url'] ?? null,
            'is_published' => true,
            'published_at' => now(),
        ]);
    }

    public function quizzes(User $user): Collection
    {
        return Quiz::query()
            ->whereIn('subject_id', $this->assignedSubjectIds($user))
            ->latest()
            ->get();
    }

    public function createQuiz(User $user, array $payload): Quiz
    {
        return Quiz::query()->create([
            'subject_id' => $payload['subject_id'] ?? $this->resolveDefaultSubjectId($user),
            'created_by' => $user->id,
            'title' => $payload['title'],
            'week_number' => $payload['week_number'] ?? 1,
            'owner_name' => $payload['owner_name'] ?? ($user->full_name ?: $user->username),
            'quiz_type' => $payload['quiz_type'] ?? 'offline',
            'quiz_link' => $payload['quiz_link'] ?? null,
            'quiz_date' => $payload['quiz_date'] ?? now()->toDateString(),
            'is_published' => true,
        ]);
    }

    public function tasks(User $user): Collection
    {
        return Task::query()
            ->whereIn('subject_id', $this->assignedSubjectIds($user))
            ->latest()
            ->get();
    }

    public function createTask(User $user, array $payload): Task
    {
        return Task::query()->create([
            'subject_id' => $payload['subject_id'] ?? $this->resolveDefaultSubjectId($user),
            'created_by' => $user->id,
            'title' => $payload['title'],
            'week_number' => $payload['week_number'] ?? 1,
            'owner_name' => $payload['owner_name'] ?? ($user->full_name ?: $user->username),
            'lecture_or_section_name' => $payload['lecture_or_section_name'] ?? 'Weekly task',
            'due_date' => $payload['due_date'] ?? now()->addWeek()->toDateString(),
            'is_published' => true,
        ]);
    }

    public function schedule(User $user): Collection
    {
        return ScheduleEvent::query()
            ->where(function ($query) use ($user) {
                $query->where('staff_user_id', $user->id)
                    ->orWhereIn('subject_id', $this->assignedSubjectIds($user));
            })
            ->orderBy('event_date')
            ->get();
    }

    public function notifications(User $user): Collection
    {
        return UserNotification::query()
            ->where(function ($query) use ($user) {
                $query->where('target_user_id', $user->id)
                    ->orWhere('is_global', true);
            })
            ->latest()
            ->get();
    }

    public function markNotificationRead(User $user, UserNotification $notification): UserNotification
    {
        abort_unless($notification->target_user_id === $user->id || $notification->is_global, Response::HTTP_FORBIDDEN, 'Notification access denied.');
        $notification->update(['is_read' => true]);

        return $notification;
    }

    public function uploads(User $user): Collection
    {
        return Attachment::query()->where('uploaded_by', $user->id)->latest('created_at')->get();
    }

    public function subjectGroup(User $user, Subject $subject): array
    {
        $subject = $this->subject($user, $subject);
        $group = $this->resolveSubjectGroup($user, $subject);

        $posts = Post::query()
            ->with(['author', 'comments.author'])
            ->where('group_id', $group->id)
            ->orderByDesc('is_pinned')
            ->orderByDesc('published_at')
            ->orderByDesc('created_at')
            ->get();

        $latestComments = Comment::query()
            ->with(['author', 'post'])
            ->whereHas('post', fn (Builder $query) => $query->where('group_id', $group->id))
            ->latest()
            ->take(8)
            ->get();

        $activity = collect()
            ->merge($posts->map(fn (Post $post) => [
                'id' => $post->id,
                'title' => $post->title ?: 'New post',
                'subtitle' => ($post->author?->full_name ?: $post->author?->username ?: 'Staff').' posted in the course group',
                'type' => $post->post_type ?: 'post',
                'created_at' => optional($post->created_at)->toIso8601String(),
            ]))
            ->merge($latestComments->map(fn (Comment $comment) => [
                'id' => $comment->id,
                'title' => 'New comment',
                'subtitle' => ($comment->author?->full_name ?: $comment->author?->username ?: 'User').' commented on a course post',
                'type' => 'comment',
                'created_at' => optional($comment->created_at)->toIso8601String(),
            ]))
            ->sortByDesc('created_at')
            ->take(10)
            ->values();

        return [
            'subject_id' => $subject->id,
            'subject_name' => $subject->name,
            'subject_code' => $subject->code,
            'group_name' => $group->name,
            'summary' => 'Posts, comments, and announcements for the teaching team and enrolled students of '.$subject->name.'.',
            'posts_count' => $posts->count(),
            'comments_count' => $latestComments->count(),
            'engagement_count' => $posts->sum(fn (Post $post) => $post->comments->count()),
            'posts' => $posts->map(fn (Post $post) => $this->subjectPostPayload($post, $subject))->values()->all(),
            'latest_comments' => $latestComments->map(fn (Comment $comment) => [
                'id' => $comment->id,
                'post_id' => $comment->post_id,
                'author_name' => $comment->author?->full_name ?: $comment->author?->username ?: 'User',
                'author_role' => $comment->author?->role_type ?: 'student',
                'message' => $comment->text,
                'created_at' => optional($comment->created_at)->toIso8601String(),
            ])->values()->all(),
            'activity' => $activity->all(),
        ];
    }

    public function saveSubjectPost(User $user, Subject $subject, array $payload): array
    {
        $group = $this->resolveSubjectGroup($user, $subject);

        $post = Post::query()->create([
            'group_id' => $group->id,
            'author_user_id' => $user->id,
            'title' => $payload['title'],
            'content_text' => $payload['content'],
            'post_type' => $payload['post_type'] ?? 'post',
            'priority' => $payload['priority'] ?? 'normal',
            'visibility' => 'course_group',
            'is_published' => true,
            'published_at' => now(),
            'is_pinned' => $payload['is_pinned'] ?? false,
            'attachment_label' => $payload['attachment_label'] ?? null,
            'attachment_url' => $payload['attachment_url'] ?? null,
        ]);

        $this->auditLogService->log($user, 'staff-portal.group-post.create', $post, [], request());

        return $this->subjectPostPayload($post->load(['author', 'comments.author']), $subject);
    }

    public function updateSubjectPost(User $user, Post $post, array $payload): array
    {
        $subject = $post->group?->courseOffering?->subject;
        abort_unless($subject instanceof Subject, Response::HTTP_UNPROCESSABLE_ENTITY, 'Post is not linked to a teaching subject.');
        $this->subject($user, $subject);

        $post->update([
            'title' => $payload['title'],
            'content_text' => $payload['content'],
            'post_type' => $payload['post_type'] ?? $post->post_type,
            'priority' => $payload['priority'] ?? $post->priority,
            'is_pinned' => $payload['is_pinned'] ?? $post->is_pinned,
            'attachment_label' => $payload['attachment_label'] ?? $post->attachment_label,
            'attachment_url' => $payload['attachment_url'] ?? $post->attachment_url,
        ]);

        $this->auditLogService->log($user, 'staff-portal.group-post.update', $post, [], request());

        return $this->subjectPostPayload($post->fresh(['author', 'comments.author']), $subject);
    }

    public function deleteSubjectPost(User $user, Post $post): void
    {
        $subject = $post->group?->courseOffering?->subject;
        abort_unless($subject instanceof Subject, Response::HTTP_UNPROCESSABLE_ENTITY, 'Post is not linked to a teaching subject.');
        $this->subject($user, $subject);

        $this->auditLogService->log($user, 'staff-portal.group-post.delete', $post, [], request());
        $post->delete();
    }

    public function togglePinnedPost(User $user, Post $post): array
    {
        $subject = $post->group?->courseOffering?->subject;
        abort_unless($subject instanceof Subject, Response::HTTP_UNPROCESSABLE_ENTITY, 'Post is not linked to a teaching subject.');
        $this->subject($user, $subject);

        $post->update(['is_pinned' => ! $post->is_pinned]);
        $this->auditLogService->log($user, 'staff-portal.group-post.pin-toggle', $post, [], request());

        return $this->subjectPostPayload($post->fresh(['author', 'comments.author']), $subject);
    }

    public function resultsOverview(User $user): array
    {
        $subjects = $this->subjects($user);
        $subjectPayloads = $subjects->map(fn (Subject $subject) => $this->subjectResults($user, $subject))->values();

        return [
            'subjects' => $subjectPayloads->map(fn (array $result) => [
                'subject_id' => $result['subject_id'],
                'subject_name' => $result['subject_name'],
                'subject_code' => $result['subject_code'],
                'status_label' => $result['status_label'],
                'latest_activity_label' => $result['recent_activity'][0]['title'] ?? 'No recent grading activity',
                'average_score' => $result['average_score'],
                'pending_review_count' => $result['pending_review_count'],
                'published_results_count' => $result['published_results_count'],
                'students_count' => count($result['students']),
            ])->all(),
            'pending_grades' => $subjectPayloads->map(fn (array $result) => [
                'id' => $result['subject_id'],
                'title' => $result['subject_code'].' grading queue',
                'subtitle' => $result['pending_review_count'].' items pending review',
                'status_label' => 'Draft',
                'created_at' => now()->subMinutes((int) $result['subject_id'])->toIso8601String(),
            ])->all(),
            'recently_published' => $subjectPayloads->map(fn (array $result) => [
                'id' => $result['subject_id'] + 1000,
                'title' => $result['subject_code'].' published results',
                'subtitle' => $result['published_results_count'].' categories visible to students',
                'status_label' => 'Published',
                'created_at' => now()->subHours(2)->toIso8601String(),
            ])->all(),
            'needs_review' => $subjectPayloads->map(fn (array $result) => [
                'id' => $result['subject_id'] + 2000,
                'title' => $result['subject_code'].' review check',
                'subtitle' => $result['pending_review_count'].' entries still need validation',
                'status_label' => $result['pending_review_count'] > 0 ? 'Needs review' : 'Published',
                'created_at' => now()->subHours(5)->toIso8601String(),
            ])->all(),
            'analytics' => [
                'average_score' => round($subjectPayloads->avg('average_score') ?: 0, 1),
                'missing_grades' => (int) $subjectPayloads->sum('pending_review_count'),
                'attendance_completion' => 88,
                'graded_quizzes' => 7,
                'pending_quizzes' => 3,
                'top_performer_label' => 'Top performance snapshot ready',
                'low_performer_label' => 'Low performance snapshot ready',
            ],
        ];
    }

    public function subjectResults(User $user, Subject $subject): array
    {
        $subject = $this->subject($user, $subject);
        $offerings = $this->subjectOfferings($user, $subject);
        $students = $this->subjectStudents($user, $subject);
        $gradeItems = GradeItem::query()
            ->with(['student'])
            ->whereIn('course_offering_id', $offerings->pluck('id'))
            ->get();
        $categories = $this->categoryDefinitions($user);

        $categoryPayload = collect($categories)->map(function (array $category) use ($gradeItems, $students, $user) {
            $items = $gradeItems->where('type', $category['type']);
            $gradedCount = $items->whereNotNull('score')->count();
            $averageScore = round((float) ($items->avg('score') ?? 0), 1);

            return [
                'key' => $category['key'],
                'label' => $category['label'],
                'max_score' => $category['max_score'],
                'status_label' => $items->where('status', 'draft')->isNotEmpty()
                    ? 'Draft'
                    : ($items->where('status', 'review')->isNotEmpty() ? 'Needs review' : 'Published'),
                'average_score' => $averageScore,
                'graded_count' => $gradedCount,
                'missing_count' => max(0, count($students) - $gradedCount),
                'is_editable' => in_array($category['key'], $this->allowedEditableCategoryKeys($user), true),
            ];
        })->values();

        $studentPayload = collect($students)->map(function (array $student) use ($categories, $gradeItems) {
            $entries = [];
            foreach ($categories as $category) {
                $grade = $gradeItems
                    ->where('student_user_id', $student['student_id'])
                    ->where('type', $category['type'])
                    ->sortByDesc('updated_at')
                    ->first();
                $entries[$category['key']] = [
                    'score' => $grade?->score !== null ? (float) $grade->score : null,
                    'max_score' => $grade?->max_score !== null ? (float) $grade->max_score : $category['max_score'],
                    'status_label' => $grade?->status ?? 'Draft',
                    'note' => $grade?->note,
                ];
            }

            $statusLabel = collect($entries)->contains(fn (array $entry) => $entry['status_label'] === 'draft')
                ? 'Draft'
                : (collect($entries)->contains(fn (array $entry) => $entry['status_label'] === 'review') ? 'Needs review' : 'Published');

            return [
                'student_id' => $student['student_id'],
                'student_name' => $student['name'],
                'student_code' => $student['code'],
                'status_label' => $statusLabel,
                'notes' => $student['status_label'],
                'entries' => $entries,
            ];
        })->values();

        $recentActivity = $gradeItems->sortByDesc('updated_at')->take(6)->map(fn (GradeItem $grade) => [
            'id' => $grade->id,
            'title' => ($grade->type?->value ?? 'GRADE').' updated',
            'subtitle' => ($grade->student?->full_name ?: $grade->student?->username ?: 'Student').' in '.$subject->code,
            'status_label' => match ($grade->status) {
                'published' => 'Published',
                'review' => 'Needs review',
                default => 'Draft',
            },
            'created_at' => optional($grade->updated_at)->toIso8601String(),
        ])->values();

        return [
            'subject_id' => $subject->id,
            'subject_name' => $subject->name,
            'subject_code' => $subject->code,
            'status_label' => $categoryPayload->contains(fn (array $item) => $item['status_label'] !== 'Published') ? 'Needs review' : 'Published',
            'categories' => $categoryPayload->all(),
            'students' => $studentPayload->all(),
            'recent_activity' => $recentActivity->all(),
            'analytics' => [
                'average_score' => round((float) ($gradeItems->avg('score') ?? 0), 1),
                'missing_grades' => (int) $categoryPayload->sum('missing_count'),
                'attendance_completion' => 90,
                'graded_quizzes' => $gradeItems->where('type', GradeType::QUIZ)->count(),
                'pending_quizzes' => max(0, count($students) - $gradeItems->where('type', GradeType::QUIZ)->count()),
                'top_performer_label' => $studentPayload->first()['student_name'] ?? '',
                'low_performer_label' => $studentPayload->last()['student_name'] ?? '',
            ],
            'allowed_category_keys' => $this->allowedEditableCategoryKeys($user),
            'average_score' => round((float) ($gradeItems->avg('score') ?? 0), 1),
            'pending_review_count' => $studentPayload->where('status_label', '!=', 'Published')->count(),
            'published_results_count' => $categoryPayload->where('status_label', 'Published')->count(),
        ];
    }

    public function subjectStudents(User $user, Subject $subject): array
    {
        $subject = $this->subject($user, $subject);
        $offerings = $this->subjectOfferings($user, $subject);

        return Enrollment::query()
            ->with(['student', 'courseOffering.section'])
            ->whereIn('course_offering_id', $offerings->pluck('id'))
            ->active()
            ->get()
            ->map(fn (Enrollment $enrollment) => [
                'student_id' => $enrollment->student?->id,
                'name' => $enrollment->student?->full_name ?: $enrollment->student?->username ?: 'Student',
                'code' => $enrollment->student?->studentProfile?->student_code ?: 'STD-'.$enrollment->student_user_id,
                'section_label' => $enrollment->courseOffering?->section?->name ?: 'Section',
                'status_label' => 'Active',
                'average_score' => round((float) ($enrollment->student?->gradeItems()->avg('score') ?? 0), 1),
                'attendance_rate' => 88,
            ])->values()->all();
    }

    public function gradingCategories(User $user, Subject $subject): array
    {
        $this->subject($user, $subject);

        return [
            'subject_id' => $subject->id,
            'allowed_category_keys' => $this->allowedEditableCategoryKeys($user),
            'categories' => collect($this->categoryDefinitions($user))->map(fn (array $category) => [
                'key' => $category['key'],
                'label' => $category['label'],
                'max_score' => $category['max_score'],
                'is_editable' => in_array($category['key'], $this->allowedEditableCategoryKeys($user), true),
            ])->values()->all(),
        ];
    }

    public function saveSubjectGrades(User $user, Subject $subject, array $payload, bool $publish): array
    {
        $subject = $this->subject($user, $subject);
        abort_unless(in_array($payload['category_key'], $this->allowedEditableCategoryKeys($user), true), Response::HTTP_FORBIDDEN, 'This role cannot update the selected grading category.');

        $offering = $this->resolveSubjectCourseOffering($user, $subject);
        $type = $this->resolveGradeType($payload['category_key']);

        DB::transaction(function () use ($payload, $publish, $user, $offering, $type) {
            foreach ($payload['entries'] as $entry) {
                $studentId = User::query()
                    ->whereHas('studentProfile', fn (Builder $query) => $query->where('student_code', $entry['student_code']))
                    ->value('id');

                if (! $studentId) {
                    continue;
                }

                GradeItem::query()->updateOrCreate(
                    [
                        'course_offering_id' => $offering->id,
                        'student_user_id' => $studentId,
                        'type' => $type,
                    ],
                    [
                        'score' => $entry['score'] ?? null,
                        'max_score' => $payload['max_score'],
                        'status' => $publish ? 'published' : 'draft',
                        'published_at' => $publish ? now() : null,
                        'entered_by_role' => $user->role_type,
                        'note' => $entry['note'] ?? null,
                        'updated_by' => $user->id,
                    ],
                );
            }
        });

        $this->auditLogService->log($user, $publish ? 'staff-portal.grades.publish' : 'staff-portal.grades.save-draft', $subject, $payload, request());

        return $this->subjectResults($user, $subject);
    }

    public function upload(User $user, UploadedFile $file): Attachment
    {
        $path = $file->store('portal-uploads', 'public');

        return Attachment::query()->create([
            'attachable_type' => User::class,
            'attachable_id' => $user->id,
            'file_url' => Storage::disk('public')->url($path),
            'file_name' => $file->getClientOriginalName(),
            'mime_type' => $file->getMimeType() ?: 'application/octet-stream',
            'size' => $file->getSize() ?: 0,
            'uploaded_by' => $user->id,
            'created_at' => now(),
        ]);
    }

    protected function assignedSubjectIds(User $user)
    {
        return $user->staffAssignments()
            ->pluck('subject_id')
            ->merge($this->managedCourseOfferingQuery($user)->pluck('subject_id'))
            ->filter()
            ->unique()
            ->values();
    }

    protected function resolveDefaultSubjectId(User $user): int
    {
        $subjectId = $this->assignedSubjectIds($user)->first();

        if (! $subjectId) {
            throw new ApiException('No subject assignment found for this account.', [], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        return (int) $subjectId;
    }

    protected function resolveDefaultCourseOfferingId(User $user, int $subjectId): int
    {
        $courseOfferingId = $this->managedCourseOfferingQuery($user)
            ->where('subject_id', $subjectId)
            ->value('id');

        if (! $courseOfferingId) {
            throw new ApiException('No course offering found for this subject assignment.', [], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        return (int) $courseOfferingId;
    }

    protected function resolveSubjectGroup(User $user, Subject $subject): GroupChat
    {
        $offering = $this->resolveSubjectCourseOffering($user, $subject);

        if ($offering->group instanceof GroupChat) {
            return $offering->group;
        }

        $group = GroupChat::query()->create([
            'course_offering_id' => $offering->id,
            'name' => $subject->code.' Course Group',
            'description' => 'Academic discussion feed for '.$subject->name,
            'created_by' => $user->id,
        ]);

        $offering->update(['group_id' => $group->id]);

        return $group;
    }

    protected function resolveSubjectCourseOffering(User $user, Subject $subject): CourseOffering
    {
        $offering = $this->managedCourseOfferingQuery($user)
            ->where('subject_id', $subject->id)
            ->with(['group', 'subject', 'section'])
            ->first();

        if (! $offering) {
            throw new ApiException('No course offering found for this subject assignment.', [], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        return $offering;
    }

    protected function subjectOfferings(User $user, Subject $subject): Collection
    {
        return $this->managedCourseOfferingQuery($user)
            ->with(['subject', 'section'])
            ->where('subject_id', $subject->id)
            ->get();
    }

    protected function subjectSummaryPayload(User $user, Subject $subject): array
    {
        $offerings = $this->subjectOfferings($user, $subject);
        $studentsCount = Enrollment::query()
            ->whereIn('course_offering_id', $offerings->pluck('id'))
            ->active()
            ->count();
        $lecturesCount = Lecture::query()->where('subject_id', $subject->id)->count();
        $sectionsCount = AcademicSectionContent::query()->where('subject_id', $subject->id)->count();
        $quizzesCount = Quiz::query()->where('subject_id', $subject->id)->count();
        $tasksCount = Task::query()->where('subject_id', $subject->id)->count();
        $postsCount = Post::query()
            ->whereHas('group.courseOffering', fn (Builder $query) => $query->where('subject_id', $subject->id))
            ->count();
        $averageScore = GradeItem::query()
            ->whereIn('course_offering_id', $offerings->pluck('id'))
            ->avg('score');
        $pendingGradesCount = GradeItem::query()
            ->whereIn('course_offering_id', $offerings->pluck('id'))
            ->where('status', '!=', 'published')
            ->count();
        $publishedResultsCount = GradeItem::query()
            ->whereIn('course_offering_id', $offerings->pluck('id'))
            ->where('status', 'published')
            ->count();
        $lastLecture = Lecture::query()->where('subject_id', $subject->id)->latest('updated_at')->first();

        return [
            'id' => $subject->id,
            'name' => $subject->name,
            'code' => $subject->code,
            'description' => $subject->description,
            'department_name' => $subject->department?->name,
            'academic_year_name' => $subject->academicYear?->name ?? (string) $subject->grade_year,
            'is_active' => $subject->is_active,
            'doctor_name' => $offerings->first()?->doctor?->full_name ?: $offerings->first()?->doctor?->username,
            'assistant_name' => $offerings->first()?->ta?->full_name ?: $offerings->first()?->ta?->username,
            'student_count' => $studentsCount,
            'lectures_count' => $lecturesCount,
            'sections_count' => $sectionsCount,
            'quizzes_count' => $quizzesCount,
            'tasks_count' => $tasksCount,
            'progress' => min(1, round((($lecturesCount + $quizzesCount + $tasksCount) / max(1, $lecturesCount + $quizzesCount + $tasksCount + $pendingGradesCount)) * 100) / 100),
            'last_activity_label' => $lastLecture?->title ? 'Latest lecture: '.$lastLecture->title : 'No lecture activity yet',
            'status_label' => $pendingGradesCount > 0 ? 'Needs review' : 'Healthy',
            'level_label' => trim(($subject->academicYear?->name ?? '').' / '.($subject->semester?->value ?? '')),
            'average_score' => round((float) ($averageScore ?? 0), 1),
            'pending_grades_count' => $pendingGradesCount,
            'published_results_count' => $publishedResultsCount,
            'group_posts_count' => $postsCount,
            'sections' => $subject->sections->map(fn ($section) => [
                'id' => $section->id,
                'name' => $section->name,
                'code' => $section->code,
                'assistant_name' => $section->assistant?->full_name ?: $section->assistant?->username,
                'is_active' => $section->is_active,
            ])->values()->all(),
        ];
    }

    protected function lecturePayload(Lecture $lecture): array
    {
        $status = ! $lecture->is_published
            ? 'Draft'
            : ($lecture->starts_at && now()->lt($lecture->starts_at) ? 'Scheduled' : 'Published');

        return [
            'id' => $lecture->id,
            'subject_id' => $lecture->subject_id,
            'subject_name' => $lecture->subject?->name,
            'title' => $lecture->title,
            'description' => $lecture->description,
            'week_number' => $lecture->week_number,
            'instructor_name' => $lecture->instructor_name,
            'video_url' => $lecture->video_url,
            'file_url' => $lecture->file_path,
            'is_published' => $lecture->is_published,
            'published_at' => optional($lecture->published_at)->toIso8601String(),
            'status_label' => $status,
            'delivery_mode' => $lecture->delivery_mode ?: 'in_person',
            'meeting_url' => $lecture->meeting_url,
            'starts_at' => optional($lecture->starts_at)->toIso8601String(),
            'ends_at' => optional($lecture->ends_at)->toIso8601String(),
            'location_label' => $lecture->location_label,
            'attachment_label' => $lecture->attachment_label,
            'publisher_name' => $lecture->author?->full_name ?: $lecture->author?->username,
        ];
    }

    protected function subjectPostPayload(Post $post, Subject $subject): array
    {
        return [
            'id' => $post->id,
            'subject_id' => $subject->id,
            'title' => $post->title ?: 'Course post',
            'content' => $post->content_text,
            'author_name' => $post->author?->full_name ?: $post->author?->username ?: 'Staff',
            'author_role' => $post->author?->role_type ?: 'staff',
            'type' => $post->post_type ?: 'post',
            'priority' => $post->priority ?: 'normal',
            'is_pinned' => (bool) $post->is_pinned,
            'comments_count' => $post->comments instanceof Collection ? $post->comments->count() : 0,
            'reactions_count' => $post->comments instanceof Collection ? $post->comments->count() : 0,
            'attachment_label' => $post->attachment_label,
            'attachment_url' => $post->attachment_url,
            'created_at' => optional($post->created_at)->toIso8601String(),
            'updated_at' => optional($post->updated_at)->toIso8601String(),
            'comments' => $post->comments instanceof Collection ? $post->comments->take(4)->map(fn (Comment $comment) => [
                'id' => $comment->id,
                'post_id' => $comment->post_id,
                'author_name' => $comment->author?->full_name ?: $comment->author?->username ?: 'User',
                'author_role' => $comment->author?->role_type ?: 'student',
                'message' => $comment->text,
                'created_at' => optional($comment->created_at)->toIso8601String(),
            ])->values()->all() : [],
        ];
    }

    protected function categoryDefinitions(User $user): array
    {
        return [
            ['key' => 'midterm', 'label' => 'Midterm', 'type' => GradeType::MIDTERM, 'max_score' => 20.0],
            ['key' => 'quiz', 'label' => 'Quiz', 'type' => GradeType::QUIZ, 'max_score' => 10.0],
            ['key' => 'oral', 'label' => 'Oral', 'type' => GradeType::ORAL, 'max_score' => 10.0],
            ['key' => 'sheets', 'label' => 'Sheets / Assignments', 'type' => GradeType::SHEET, 'max_score' => 15.0],
            ['key' => 'attendance', 'label' => 'Attendance', 'type' => GradeType::ATTENDANCE, 'max_score' => 5.0],
            ['key' => 'coursework', 'label' => 'Coursework / Year work', 'type' => GradeType::COURSEWORK, 'max_score' => 20.0],
            ['key' => 'final', 'label' => 'Final', 'type' => GradeType::FINAL, 'max_score' => 40.0],
        ];
    }

    protected function allowedEditableCategoryKeys(User $user): array
    {
        if ($user->isAdmin()) {
            return ['midterm', 'quiz', 'oral', 'sheets', 'attendance', 'coursework', 'final'];
        }

        if ($user->role?->value === 'DOCTOR' || $user->role_type === 'doctor') {
            return ['midterm'];
        }

        return ['quiz', 'oral', 'sheets', 'attendance', 'coursework'];
    }

    protected function resolveGradeType(string $categoryKey): GradeType
    {
        return match ($categoryKey) {
            'midterm' => GradeType::MIDTERM,
            'quiz' => GradeType::QUIZ,
            'oral' => GradeType::ORAL,
            'sheets' => GradeType::SHEET,
            'attendance' => GradeType::ATTENDANCE,
            'coursework' => GradeType::COURSEWORK,
            'final' => GradeType::FINAL,
            default => GradeType::OTHER,
        };
    }

    protected function startsAtFromPayload(array $payload): ?string
    {
        if (empty($payload['publish_date'])) {
            return null;
        }

        return trim((string) $payload['publish_date'].' '.($payload['publish_time'] ?? '09:00')).':00';
    }

    protected function endsAtFromPayload(array $payload): ?string
    {
        $startsAt = $this->startsAtFromPayload($payload);
        if (! $startsAt) {
            return null;
        }

        return \Carbon\Carbon::parse($startsAt)->addHours(2)->toDateTimeString();
    }

    protected function managedCourseOfferingQuery(User $user): Builder
    {
        return CourseOffering::query()
            ->when(
                $user->role?->value === 'DOCTOR',
                fn (Builder $query) => $query->where('doctor_user_id', $user->id),
                fn (Builder $query) => $query->where('ta_user_id', $user->id),
            );
    }
}
