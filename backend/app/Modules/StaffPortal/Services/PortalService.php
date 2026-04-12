<?php

namespace App\Modules\StaffPortal\Services;

use App\Core\Exceptions\ApiException;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Academic\Models\Subject;
use App\Modules\Content\Models\Attachment;
use App\Modules\Content\Models\Lecture;
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
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\Response;

class PortalService
{
    public function __construct(protected AuditLogService $auditLogService)
    {
    }

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
            ->with(['department', 'academicYear', 'sections.assistant'])
            ->whereIn('id', $subjectIds)
            ->get();
    }

    public function subject(User $user, Subject $subject): Subject
    {
        abort_unless($this->assignedSubjectIds($user)->contains($subject->id) || $user->isAdmin(), Response::HTTP_FORBIDDEN, 'You are not assigned to this subject.');

        return $subject->load(['department', 'academicYear', 'sections.assistant']);
    }

    public function lectures(User $user): Collection
    {
        return Lecture::query()
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
            'week_number' => $payload['week_number'] ?? 1,
            'instructor_name' => $payload['instructor_name'] ?? ($user->full_name ?: $user->username),
            'video_url' => $payload['video_url'] ?? null,
            'is_published' => true,
            'published_at' => now(),
        ]);

        $this->auditLogService->log($user, 'staff-portal.lecture.create', $lecture, [], request());

        return $lecture;
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
