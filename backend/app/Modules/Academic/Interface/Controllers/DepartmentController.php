<?php

namespace App\Modules\Academic\Interface\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Academic\Infrastructure\Department;
use App\Modules\Academic\Interface\Requests\StoreDepartmentRequest;
use App\Modules\Academic\Interface\Resources\DepartmentResource;
use App\Modules\Academic\Application\AcademicService;

class DepartmentController extends ApiController
{
    public function __construct(protected AcademicService $academicService) {}

        /**
     * @OA\Get(
     *     path="/api/departments",
     *     summary="index action in DepartmentController",
     *     tags={"Academic"},
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest")
     * )
     */
    public function index()
    {
        return $this->success('Departments retrieved successfully.', DepartmentResource::collection(Department::query()->orderBy('name')->get()));
    }

        /**
     * @OA\Post(
     *     path="/api/admin/departments",
     *     summary="store action in DepartmentController",
     *     tags={"Academic"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"name"},
     *             @OA\Property(property="name", type="string", description="Rules: required, string, max:150, unique:departments,name")
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
    public function store(StoreDepartmentRequest $request)
    {
        $department = $this->academicService->createDepartment($request->validated(), $request->user());

        return $this->success('Department created successfully.', DepartmentResource::make($department), 201);
    }
}
