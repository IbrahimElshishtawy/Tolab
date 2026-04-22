<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\StaffPortal\Requests\StoreTaskPortalRequest;
use App\Modules\StaffPortal\Resources\TaskPortalResource;
use App\Modules\StaffPortal\Services\PortalService;
use Illuminate\Http\Request;

class TaskController extends ApiController
{
    public function __construct(protected PortalService $service) {}

    public function index(Request $request)
    {
        return $this->success('Tasks retrieved successfully.', TaskPortalResource::collection($this->service->tasks($request->user())));
    }

    public function store(StoreTaskPortalRequest $request)
    {
        return $this->success('Task created successfully.', TaskPortalResource::make($this->service->createTask($request->user(), $request->validated())), 201);
    }
}
