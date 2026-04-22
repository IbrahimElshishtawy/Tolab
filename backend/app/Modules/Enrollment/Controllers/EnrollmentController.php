<?php

namespace App\Modules\Enrollment\Controllers;

use App\Core\Base\ApiController;
use App\Core\Services\PaginationSanitizer;
use App\Modules\Enrollment\Models\Enrollment;
use App\Modules\Enrollment\Requests\BulkEnrollmentRequest;
use App\Modules\Enrollment\Requests\StoreEnrollmentRequest;
use App\Modules\Enrollment\Requests\UpdateEnrollmentRequest;
use App\Modules\Enrollment\Resources\EnrollmentResource;
use App\Modules\Enrollment\Services\EnrollmentService;
use Illuminate\Http\Request;

class EnrollmentController extends ApiController
{
    public function __construct(
        protected EnrollmentService $enrollmentService,
        protected PaginationSanitizer $paginationSanitizer,
    ) {}

    public function index(Request $request)
    {
        $filters = $request->only([
            'search',
            'status',
            'course_id',
            'section_id',
            'semester',
            'academic_year',
            'staff_id',
            'sort_by',
            'sort_direction',
        ]);
        $enrollments = $this->enrollmentService->paginateAdmin(
            $filters,
            $this->paginationSanitizer->perPage($request),
        );

        return $this->success('Enrollments retrieved successfully.', [
            'items' => EnrollmentResource::collection($enrollments->getCollection())->resolve(),
            'pagination' => [
                'page' => $enrollments->currentPage(),
                'per_page' => $enrollments->perPage(),
                'total_items' => $enrollments->total(),
                'total_pages' => $enrollments->lastPage(),
            ],
            'lookups' => $this->enrollmentService->lookups(),
            'summary' => $this->enrollmentService->summary($filters),
        ]);
    }

    public function store(StoreEnrollmentRequest $request)
    {
        $enrollment = $this->enrollmentService->create($request->validated(), $request->user());

        return $this->success('Enrollment created successfully.', EnrollmentResource::make($enrollment), 201);
    }

    public function update(UpdateEnrollmentRequest $request, Enrollment $enrollment)
    {
        $updated = $this->enrollmentService->update($enrollment, $request->validated(), $request->user());

        return $this->success('Enrollment updated successfully.', EnrollmentResource::make($updated));
    }

    public function bulk(BulkEnrollmentRequest $request)
    {
        $enrollments = $this->enrollmentService->bulkCreate($request->validated(), $request->user());

        return $this->success('Enrollments created successfully.', EnrollmentResource::collection(collect($enrollments)), 201);
    }

    public function bulkUpload(BulkEnrollmentRequest $request)
    {
        return $this->bulk($request);
    }

    public function destroy(Enrollment $enrollment)
    {
        $this->enrollmentService->delete($enrollment, request()->user());

        return $this->success('Enrollment deleted successfully.');
    }
}
