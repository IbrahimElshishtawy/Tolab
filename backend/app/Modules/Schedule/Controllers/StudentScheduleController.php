<?php

namespace App\Modules\Schedule\Controllers;

use App\Core\Base\ApiController;
use App\Core\Enums\WeekPattern;
use App\Modules\Schedule\Requests\TimetableFilterRequest;
use App\Modules\Schedule\Resources\ScheduleEventResource;
use App\Modules\Schedule\Services\ScheduleService;

class StudentScheduleController extends ApiController
{
    public function __construct(protected ScheduleService $scheduleService)
    {
    }

    public function index(TimetableFilterRequest $request)
    {
        $week = WeekPattern::tryFrom((string) $request->validated('week', WeekPattern::ALL->value)) ?? WeekPattern::ALL;
        $events = $this->scheduleService->studentTimetable($request->user(), $week->value);

        return $this->success(
            'Timetable retrieved successfully.',
            ScheduleEventResource::collection($events),
            200,
            ['week' => $week->value, 'count' => $events->count()]
        );
    }
}
