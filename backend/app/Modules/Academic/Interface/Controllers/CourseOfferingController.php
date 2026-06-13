<?php

namespace App\Modules\Academic\Interface\Controllers;

use App\Core\Base\ApiController;
use App\Core\Services\PaginationSanitizer;
use App\Modules\Academic\Infrastructure\CourseOffering;
use App\Modules\Academic\Interface\Requests\StoreCourseOfferingRequest;
use App\Modules\Academic\Interface\Requests\UpdateCourseOfferingRequest;
use App\Modules\Academic\Interface\Resources\CourseOfferingResource;
use App\Modules\Academic\Application\CourseOfferingService;
use Illuminate\Http\Request;

class CourseOfferingController extends ApiController
{
    public function __construct(
        protected CourseOfferingService $service,
        protected PaginationSanitizer $paginationSanitizer,
    ) {}

    public function index(Request $request)
    {
        $offerings = $this->service->paginateAdmin(
            $request->only(['section_id', 'subject_id', 'year', 'semester']),
            $this->paginationSanitizer->perPage($request)
        );

        return $this->success('Course offerings retrieved successfully.', CourseOfferingResource::collection($offerings));
    }

        /**
     * @OA\Post(
     *     path="/api/admin/course-offerings",
     *     summary="store action in CourseOfferingController",
     *     tags={"Academic"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"subject_id", "section_id", "academic_year", "semester"},
     *             @OA\Property(property="subject_id", type="integer", description="Rules: required, integer, exists:subjects,id"),
     *             @OA\Property(property="section_id", type="integer", description="Rules: required, integer, exists:sections,id"),
     *             @OA\Property(property="academic_year", type="string", description="Rules: required, string, max:20"),
     *             @OA\Property(property="semester", type="string", description="Rules: required, Illuminate\Validation\Rules\Enum"),
     *             @OA\Property(property="doctor_user_id", type="integer", description="Rules: nullable, integer, exists:users,id"),
     *             @OA\Property(property="ta_user_id", type="integer", description="Rules: nullable, integer, exists:users,id")
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
    public function store(StoreCourseOfferingRequest $request)
    {
        $offering = $this->service->create($request->validated(), $request->user());

        return $this->success('Course offering created successfully.', CourseOfferingResource::make($offering), 201);
    }

        /**
     * @OA\Put(
     *     path="/api/admin/course-offerings/{courseOffering}",
     *     summary="update action in CourseOfferingController",
     *     tags={"Academic"},
     *     @OA\Parameter(
     *         name="courseOffering",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The courseOffering parameter"
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="subject_id", type="integer", description="Rules: sometimes, integer, exists:subjects,id"),
     *             @OA\Property(property="section_id", type="integer", description="Rules: sometimes, integer, exists:sections,id"),
     *             @OA\Property(property="academic_year", type="string", description="Rules: sometimes, string, max:20"),
     *             @OA\Property(property="semester", type="string", description="Rules: sometimes, Illuminate\Validation\Rules\Enum"),
     *             @OA\Property(property="doctor_user_id", type="integer", description="Rules: nullable, integer, exists:users,id"),
     *             @OA\Property(property="ta_user_id", type="integer", description="Rules: nullable, integer, exists:users,id")
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
    public function update(UpdateCourseOfferingRequest $request, CourseOffering $courseOffering)
    {
        $offering = $this->service->update($courseOffering, $request->validated(), $request->user());

        return $this->success('Course offering updated successfully.', CourseOfferingResource::make($offering));
    }
}
