<?php

namespace App\Modules\Academic\Interface\Controllers;

use App\Core\Base\ApiController;
use App\Core\Services\PaginationSanitizer;
use App\Modules\Academic\Infrastructure\CourseOffering;
use App\Modules\Academic\Infrastructure\Repositories\CourseOfferingRepository;
use App\Modules\Academic\Interface\Resources\CourseOfferingResource;
use App\Modules\Content\Interface\Resources\CourseContentBundleResource;
use App\Modules\Content\Application\ContentService;
use Illuminate\Http\Request;

class StudentCourseController extends ApiController
{
    public function __construct(
        protected CourseOfferingRepository $repository,
        protected PaginationSanitizer $paginationSanitizer,
        protected ContentService $contentService,
    ) {}

        /**
     * @OA\Get(
     *     path="/api/student/courses",
     *     summary="index action in StudentCourseController",
     *     tags={"Academic"},
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
        $courses = $this->repository->paginate($this->repository->forStudent($request->user()), $this->paginationSanitizer->perPage($request));

        return $this->success('Student courses retrieved successfully.', CourseOfferingResource::collection($courses));
    }

        /**
     * @OA\Get(
     *     path="/api/student/courses/{courseOffering}",
     *     summary="show action in StudentCourseController",
     *     tags={"Academic"},
     *     @OA\Parameter(
     *         name="courseOffering",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The courseOffering parameter"
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
    public function show(CourseOffering $courseOffering)
    {
        $this->authorize('view', $courseOffering);

        return $this->success(
            'Course offering retrieved successfully.',
            CourseOfferingResource::make($courseOffering->load(['subject.department', 'section.department', 'doctor', 'ta', 'group']))
        );
    }

        /**
     * @OA\Get(
     *     path="/api/student/courses/{courseOffering}/content",
     *     summary="content action in StudentCourseController",
     *     tags={"Academic"},
     *     @OA\Parameter(
     *         name="courseOffering",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The courseOffering parameter"
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
    public function content(CourseOffering $courseOffering)
    {
        $this->authorize('view', $courseOffering);
        $content = $this->contentService->bundle($courseOffering);

        return $this->success('Course content retrieved successfully.', CourseContentBundleResource::make($content));
    }
}
