<?php

namespace App\Modules\Schedule\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Academic\Infrastructure\CourseOffering;
use App\Modules\Schedule\Models\ScheduleEvent;
use App\Modules\Schedule\Requests\BulkScheduleEventRequest;
use App\Modules\Schedule\Requests\StoreScheduleEventRequest;
use App\Modules\Schedule\Requests\UpdateScheduleEventRequest;
use App\Modules\Schedule\Resources\ScheduleEventResource;
use App\Modules\Schedule\Services\ScheduleService;
use Illuminate\Http\Request;

class ScheduleController extends ApiController
{
    public function __construct(protected ScheduleService $scheduleService) {}

        /**
     * @OA\Get(
     *     path="/api/admin/schedule-events",
     *     summary="index action in ScheduleController",
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
    public function index(Request $request)
    {
        $events = $this->scheduleService->index($request->all(), $request->user());

        return $this->success(
            'Schedule events retrieved successfully.',
            ScheduleEventResource::collection($events)
        );
    }

        /**
     * @OA\Post(
     *     path="/api/admin/courses/{courseOffering}/schedule-events",
     *     summary="store action in ScheduleController",
     *     tags={"Schedule"},
     *     @OA\Parameter(
     *         name="courseOffering",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The courseOffering parameter"
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"type", "day_of_week", "start_time", "end_time", "week_pattern"},
     *             @OA\Property(property="type", type="string", description="Rules: required, Illuminate\Validation\Rules\Enum"),
     *             @OA\Property(property="day_of_week", type="integer", description="Rules: required, integer, between:0,6"),
     *             @OA\Property(property="start_time", type="string", description="Rules: required, date_format:H:i"),
     *             @OA\Property(property="end_time", type="string", description="Rules: required, date_format:H:i, after:start_time"),
     *             @OA\Property(property="location", type="string", description="Rules: nullable, string, max:180"),
     *             @OA\Property(property="week_pattern", type="string", description="Rules: required, Illuminate\Validation\Rules\Enum"),
     *             @OA\Property(property="note", type="string", description="Rules: nullable, string")
     *         )
     *     ),
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
    public function store(StoreScheduleEventRequest $request, CourseOffering $courseOffering)
    {
        $event = $this->scheduleService->create($courseOffering, $request->validated(), $request->user());

        return $this->success('Schedule event created successfully.', ScheduleEventResource::make($event), 201);
    }

        /**
     * @OA\Post(
     *     path="/api/admin/schedule-events/bulk",
     *     summary="bulk action in ScheduleController",
     *     tags={"Schedule"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"events", "events.*.course_offering_id", "events.*.type", "events.*.day_of_week", "events.*.start_time", "events.*.end_time", "events.*.week_pattern"},
     *             @OA\Property(property="events", type="array", description="Rules: required, array, min:1"),
     *             @OA\Property(property="events.*.course_offering_id", type="integer", description="Rules: required, integer, exists:course_offerings,id"),
     *             @OA\Property(property="events.*.type", type="string", description="Rules: required, Illuminate\Validation\Rules\Enum"),
     *             @OA\Property(property="events.*.day_of_week", type="integer", description="Rules: required, integer, between:0,6"),
     *             @OA\Property(property="events.*.start_time", type="string", description="Rules: required, date_format:H:i"),
     *             @OA\Property(property="events.*.end_time", type="string", description="Rules: required, date_format:H:i"),
     *             @OA\Property(property="events.*.location", type="string", description="Rules: nullable, string, max:180"),
     *             @OA\Property(property="events.*.week_pattern", type="string", description="Rules: required, Illuminate\Validation\Rules\Enum"),
     *             @OA\Property(property="events.*.note", type="string", description="Rules: nullable, string")
     *         )
     *     ),
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
    public function bulk(BulkScheduleEventRequest $request)
    {
        $events = $this->scheduleService->bulk($request->validated(), $request->user());

        return $this->success('Schedule events created successfully.', ScheduleEventResource::collection(collect($events)), 201);
    }

        /**
     * @OA\Put(
     *     path="/api/admin/schedule-events/{scheduleEvent}",
     *     summary="update action in ScheduleController",
     *     tags={"Schedule"},
     *     @OA\Parameter(
     *         name="scheduleEvent",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The scheduleEvent parameter"
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="type", type="string", description="Rules: sometimes, Illuminate\Validation\Rules\Enum"),
     *             @OA\Property(property="day_of_week", type="integer", description="Rules: sometimes, integer, between:0,6"),
     *             @OA\Property(property="start_time", type="string", description="Rules: sometimes, date_format:H:i"),
     *             @OA\Property(property="end_time", type="string", description="Rules: sometimes, date_format:H:i"),
     *             @OA\Property(property="location", type="string", description="Rules: nullable, string, max:180"),
     *             @OA\Property(property="week_pattern", type="string", description="Rules: sometimes, Illuminate\Validation\Rules\Enum"),
     *             @OA\Property(property="note", type="string", description="Rules: nullable, string")
     *         )
     *     ),
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
    public function update(UpdateScheduleEventRequest $request, ScheduleEvent $scheduleEvent)
    {
        $event = $this->scheduleService->update($scheduleEvent, $request->validated(), $request->user());

        return $this->success('Schedule event updated successfully.', ScheduleEventResource::make($event));
    }

    public function destroy(ScheduleEvent $scheduleEvent)
    {
        $this->scheduleService->delete($scheduleEvent, request()->user());

        return $this->success('Schedule event deleted successfully.');
    }
}
