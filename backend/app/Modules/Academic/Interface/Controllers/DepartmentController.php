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

    public function index()
    {
        return $this->success('Departments retrieved successfully.', DepartmentResource::collection(Department::query()->orderBy('name')->get()));
    }

    public function store(StoreDepartmentRequest $request)
    {
        $department = $this->academicService->createDepartment($request->validated(), $request->user());

        return $this->success('Department created successfully.', DepartmentResource::make($department), 201);
    }
}
