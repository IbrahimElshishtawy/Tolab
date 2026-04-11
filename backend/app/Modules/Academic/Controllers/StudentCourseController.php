<?php

namespace App\Modules\Academic\Controllers;

use App\Core\Base\ApiController;
use App\Core\Services\PaginationSanitizer;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Academic\Repositories\CourseOfferingRepository;
use App\Modules\Academic\Resources\CourseOfferingResource;
use App\Modules\Content\Resources\CourseContentBundleResource;
use App\Modules\Content\Services\ContentService;
use Illuminate\Http\Request;

class StudentCourseController extends ApiController
{
    public function __construct(
        protected CourseOfferingRepository $repository,
        protected PaginationSanitizer $paginationSanitizer,
        protected ContentService $contentService,
    ) {
    }

    public function index(Request $request)
    {
        $courses = $this->repository->paginate($this->repository->forStudent($request->user()), $this->paginationSanitizer->perPage($request));

        return $this->success('Student courses retrieved successfully.', CourseOfferingResource::collection($courses));
    }

    public function show(CourseOffering $courseOffering)
    {
        $this->authorize('view', $courseOffering);

        return $this->success(
            'Course offering retrieved successfully.',
            CourseOfferingResource::make($courseOffering->load(['subject.department', 'section.department', 'doctor', 'ta', 'group']))
        );
    }

    public function content(CourseOffering $courseOffering)
    {
        $this->authorize('view', $courseOffering);
        $content = $this->contentService->bundle($courseOffering);

        return $this->success('Course content retrieved successfully.', CourseContentBundleResource::make($content));
    }
}
