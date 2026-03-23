<?php

namespace App\Modules\Academic\Controllers;

use App\Core\Base\ApiController;
use App\Core\Services\PaginationSanitizer;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Academic\Requests\StoreCourseOfferingRequest;
use App\Modules\Academic\Requests\UpdateCourseOfferingRequest;
use App\Modules\Academic\Resources\CourseOfferingResource;
use App\Modules\Academic\Services\CourseOfferingService;
use Illuminate\Http\Request;

class CourseOfferingController extends ApiController
{
    public function __construct(
        protected CourseOfferingService $service,
        protected PaginationSanitizer $paginationSanitizer,
    ) {
    }

    public function index(Request $request)
    {
        $offerings = $this->service->paginateAdmin(
            $request->only(['section_id', 'subject_id', 'year', 'semester']),
            $this->paginationSanitizer->perPage($request)
        );

        return $this->success('Course offerings retrieved successfully.', CourseOfferingResource::collection($offerings));
    }

    public function store(StoreCourseOfferingRequest $request)
    {
        $offering = $this->service->create($request->validated(), $request->user());

        return $this->success('Course offering created successfully.', CourseOfferingResource::make($offering), 201);
    }

    public function update(UpdateCourseOfferingRequest $request, CourseOffering $courseOffering)
    {
        $offering = $this->service->update($courseOffering, $request->validated(), $request->user());

        return $this->success('Course offering updated successfully.', CourseOfferingResource::make($offering));
    }
}
