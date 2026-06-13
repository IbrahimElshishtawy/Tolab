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

        /**
     * @OA\Get(
     *     path="/api/staff-portal/tasks",
     *     summary="index action in TaskController",
     *     tags={"StaffPortal"},
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
        return $this->success('Tasks retrieved successfully.', TaskPortalResource::collection($this->service->tasks($request->user())));
    }

    public function store(StoreTaskPortalRequest $request)
    {
        return $this->success('Task created successfully.', TaskPortalResource::make($this->service->createTask($request->user(), $request->validated())), 201);
    }
}
