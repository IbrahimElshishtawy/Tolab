<?php

namespace App\Modules\Schedule\Controllers;

use App\Core\Base\ApiController;
use App\Core\Enums\WeekPattern;
use App\Modules\Schedule\Requests\TimetableFilterRequest;
use App\Modules\Schedule\Resources\ScheduleEventResource;
use App\Modules\Schedule\Services\ScheduleService;

class StudentScheduleController extends ApiController
{
    public function __construct(protected ScheduleService $scheduleService) {}

        /**
     * @OA\Get(
     *     path="/api/student/timetable",
     *     summary="index action in StudentScheduleController",
     *     tags={"Schedule"},
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest"),
     *     @OA\Response(response=401, ref="#/components/responses/401Unauthenticated"),
     *     @OA\Response(response=403, ref="#/components/responses/403Forbidden"),
     *     security={
     *         {"sanctum": {}}
     *     }
     * )
     */
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
