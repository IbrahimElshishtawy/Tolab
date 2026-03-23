<?php

namespace App\Modules\Enrollment\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Enrollment\Models\Enrollment;
use App\Modules\Enrollment\Requests\BulkEnrollmentRequest;
use App\Modules\Enrollment\Requests\StoreEnrollmentRequest;
use App\Modules\Enrollment\Resources\EnrollmentResource;
use App\Modules\Enrollment\Services\EnrollmentService;

class EnrollmentController extends ApiController
{
    public function __construct(protected EnrollmentService $enrollmentService)
    {
    }

    public function store(StoreEnrollmentRequest $request)
    {
        $enrollment = $this->enrollmentService->create($request->validated(), $request->user());

        return $this->success('Enrollment created successfully.', EnrollmentResource::make($enrollment), 201);
    }

    public function bulk(BulkEnrollmentRequest $request)
    {
        $enrollments = $this->enrollmentService->bulkCreate($request->validated(), $request->user());

        return $this->success('Enrollments created successfully.', EnrollmentResource::collection(collect($enrollments)), 201);
    }

    public function destroy(Enrollment $enrollment)
    {
        $this->enrollmentService->delete($enrollment, request()->user());

        return $this->success('Enrollment deleted successfully.');
    }
}
