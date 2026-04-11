<?php

namespace App\Modules\Schedule\Services;

use App\Core\Exceptions\ApiException;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Schedule\Models\ScheduleEvent;
use App\Modules\Shared\Services\AuditLogService;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Collection;
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

    public function index(array $filters, User $actor): Collection
    {
        $this->ensureAllowed($actor);

        $query = ScheduleEvent::query()
            ->with([
                'courseOffering.subject.department',
                'courseOffering.section.department',
                'courseOffering.doctor',
                'courseOffering.ta',
            ]);

        $types = $this->normalizeFilters($filters['types'] ?? $filters['types[]'] ?? []);
        if ($types !== []) {
            $query->whereIn('type', $types);
        }

        if (! empty($filters['subject_id'])) {
            $query->whereHas('courseOffering', function (Builder $builder) use ($filters) {
                $builder->where('subject_id', $filters['subject_id']);
            });
        }

        if (! empty($filters['section_id'])) {
            $query->whereHas('courseOffering', function (Builder $builder) use ($filters) {
                $builder->where('section_id', $filters['section_id']);
            });
        }

        if (! empty($filters['academic_year'])) {
            $query->whereHas('courseOffering', function (Builder $builder) use ($filters) {
                $builder->where('academic_year', $filters['academic_year']);
            });
        }

        if (! empty($filters['staff_id'])) {
            $query->whereHas('courseOffering', function (Builder $builder) use ($filters) {
                $builder->where('doctor_user_id', $filters['staff_id'])
                    ->orWhere('ta_user_id', $filters['staff_id']);
            });
        }

        if (! empty($filters['department'])) {
            $department = (string) $filters['department'];
            $query->whereHas('courseOffering', function (Builder $builder) use ($department) {
                $builder->whereHas('subject.department', function (Builder $inner) use ($department) {
                    $inner->where('departments.id', $department)
                        ->orWhere('departments.name', $department);
                })->orWhereHas('section.department', function (Builder $inner) use ($department) {
                    $inner->where('departments.id', $department)
                        ->orWhere('departments.name', $department);
                });
            });
        }

        $events = $query
            ->orderBy('day_of_week')
            ->orderBy('start_time')
            ->get();

        $statuses = $this->normalizeFilters($filters['statuses'] ?? $filters['statuses[]'] ?? []);
        if ($statuses === []) {
            return $events;
        }

        return $events->filter(function (ScheduleEvent $event) use ($statuses) {
            $status = $event->resolveComputedStatus();

            return in_array($status, $statuses, true);
        })->values();
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
        $query = ScheduleEvent::query()
            ->with([
                'courseOffering.subject.department',
                'courseOffering.section.department',
                'courseOffering.doctor',
                'courseOffering.ta',
            ])
            ->whereHas('courseOffering.enrollments', fn ($builder) => $builder
                ->active()
                ->where('student_user_id', $student->id));

        if ($weekPattern !== 'ALL') {
            $query->whereIn('week_pattern', ['ALL', $weekPattern]);
        }

        return $query
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

    protected function normalizeFilters(array|string|null $value): array
    {
        if ($value === null) {
            return [];
        }

        if (is_string($value)) {
            return array_values(array_filter(array_map('trim', explode(',', $value))));
        }

        return array_values(array_filter(array_map(
            static fn (mixed $item): string => trim((string) $item),
            $value
        )));
    }
}
