<?php

namespace App\Modules\Academic\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Academic\Models\Department;
use App\Modules\Academic\Requests\StoreDepartmentRequest;
use App\Modules\Academic\Resources\DepartmentResource;
use App\Modules\Academic\Services\AcademicService;

class DepartmentController extends ApiController
{
    public function __construct(protected AcademicService $academicService)
    {
    }

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
