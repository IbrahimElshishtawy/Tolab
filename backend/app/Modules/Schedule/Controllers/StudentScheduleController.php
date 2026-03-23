<?php

namespace App\Modules\Schedule\Controllers;

use App\Core\Base\ApiController;
use App\Core\Enums\WeekPattern;
use App\Modules\Schedule\Resources\ScheduleEventResource;
use App\Modules\Schedule\Services\ScheduleService;
use Illuminate\Http\Request;

class StudentScheduleController extends ApiController
{
    public function __construct(protected ScheduleService $scheduleService)
    {
    }

    public function index(Request $request)
    {
        $week = WeekPattern::tryFrom((string) $request->get('week', WeekPattern::ALL->value)) ?? WeekPattern::ALL;
        $events = $this->scheduleService->studentTimetable($request->user(), $week->value);

        return $this->success('Timetable retrieved successfully.', ScheduleEventResource::collection($events));
    }
}
