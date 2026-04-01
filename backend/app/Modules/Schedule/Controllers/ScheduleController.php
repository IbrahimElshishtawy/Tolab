<?php

namespace App\Modules\Schedule\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Schedule\Models\ScheduleEvent;
use App\Modules\Schedule\Requests\BulkScheduleEventRequest;
use App\Modules\Schedule\Requests\StoreScheduleEventRequest;
use App\Modules\Schedule\Requests\UpdateScheduleEventRequest;
use App\Modules\Schedule\Resources\ScheduleEventResource;
use App\Modules\Schedule\Services\ScheduleService;
use Illuminate\Http\Request;

class ScheduleController extends ApiController
{
    public function __construct(protected ScheduleService $scheduleService)
    {
    }

    public function index(Request $request)
    {
        $events = $this->scheduleService->index($request->all(), $request->user());

        return $this->success(
            'Schedule events retrieved successfully.',
            ScheduleEventResource::collection($events)
        );
    }

    public function store(StoreScheduleEventRequest $request, CourseOffering $courseOffering)
    {
        $event = $this->scheduleService->create($courseOffering, $request->validated(), $request->user());

        return $this->success('Schedule event created successfully.', ScheduleEventResource::make($event), 201);
    }

    public function bulk(BulkScheduleEventRequest $request)
    {
        $events = $this->scheduleService->bulk($request->validated(), $request->user());

        return $this->success('Schedule events created successfully.', ScheduleEventResource::collection(collect($events)), 201);
    }

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
