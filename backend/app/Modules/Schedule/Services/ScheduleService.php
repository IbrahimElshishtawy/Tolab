<?php

namespace App\Modules\Schedule\Services;

use App\Core\Exceptions\ApiException;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Schedule\Models\ScheduleEvent;
use App\Modules\Shared\Services\AuditLogService;
use App\Modules\UserManagement\Models\User;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpFoundation\Response;

class ScheduleService
{
    public function __construct(protected AuditLogService $auditLogService)
    {
    }

    public function create(CourseOffering $courseOffering, array $payload, User $actor): ScheduleEvent
    {
        $this->ensureAllowed($actor);

        return DB::transaction(function () use ($courseOffering, $payload, $actor) {
            $event = $courseOffering->scheduleEvents()->create($payload);
            $this->auditLogService->log($actor, 'schedule.create', $event, [], request());

            return $event;
        });
    }

    public function bulk(array $payload, User $actor): array
    {
        $this->ensureAllowed($actor);
        $events = [];

        DB::transaction(function () use ($payload, $actor, &$events) {
            foreach ($payload['events'] as $eventPayload) {
                $offering = CourseOffering::query()->findOrFail($eventPayload['course_offering_id']);
                $events[] = $offering->scheduleEvents()->create(collect($eventPayload)->except('course_offering_id')->toArray());
            }
            $this->auditLogService->log($actor, 'schedule.bulk', null, ['count' => count($events)], request());
        });

        return $events;
    }

    public function update(ScheduleEvent $scheduleEvent, array $payload, User $actor): ScheduleEvent
    {
        $this->ensureAllowed($actor);
        $scheduleEvent->update($payload);
        $this->auditLogService->log($actor, 'schedule.update', $scheduleEvent, [], request());

        return $scheduleEvent->refresh();
    }

    public function delete(ScheduleEvent $scheduleEvent, User $actor): void
    {
        $this->ensureAllowed($actor);
        $this->auditLogService->log($actor, 'schedule.delete', $scheduleEvent, [], request());
        $scheduleEvent->delete();
    }

    public function studentTimetable(User $student, string $weekPattern)
    {
        return ScheduleEvent::query()
            ->with(['courseOffering.subject'])
            ->whereHas('courseOffering.enrollments', fn ($query) => $query->where('student_user_id', $student->id))
            ->whereIn('week_pattern', ['ALL', $weekPattern])
            ->orderBy('day_of_week')
            ->orderBy('start_time')
            ->get();
    }

    protected function ensureAllowed(User $actor): void
    {
        if (! $actor->canManageSchedule()) {
            throw new ApiException('You are not allowed to manage schedule.', [], Response::HTTP_FORBIDDEN);
        }
    }
}
