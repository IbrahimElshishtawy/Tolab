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

        /**
     * @OA\Get(
     *     path="/api/admin/enrollments",
     *     summary="index action in EnrollmentController",
     *     tags={"Enrollment"},
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

        /**
     * @OA\Put(
     *     path="/api/admin/enrollments/{enrollment}",
     *     summary="update action in EnrollmentController",
     *     tags={"Enrollment"},
     *     @OA\Parameter(
     *         name="enrollment",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The enrollment parameter"
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"student_user_id", "course_offering_id"},
     *             @OA\Property(property="student_user_id", type="integer", description="Rules: required, integer, exists:users,id"),
     *             @OA\Property(property="course_offering_id", type="integer", description="Rules: required, integer, exists:course_offerings,id"),
     *             @OA\Property(property="status", type="string", description="Rules: nullable, string, in:enrolled,pending,rejected")
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
    public function update(UpdateEnrollmentRequest $request, Enrollment $enrollment)
    {
        $updated = $this->enrollmentService->update($enrollment, $request->validated(), $request->user());

        return $this->success('Enrollment updated successfully.', EnrollmentResource::make($updated));
    }

        /**
     * @OA\Post(
     *     path="/api/admin/enrollments/bulk",
     *     summary="bulk action in EnrollmentController",
     *     tags={"Enrollment"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"enrollments", "enrollments.*.student_user_id", "enrollments.*.course_offering_id"},
     *             @OA\Property(property="enrollments", type="array", description="Rules: required, array, min:1"),
     *             @OA\Property(property="enrollments.*.student_user_id", type="integer", description="Rules: required, integer, exists:users,id"),
     *             @OA\Property(property="enrollments.*.course_offering_id", type="integer", description="Rules: required, integer, exists:course_offerings,id"),
     *             @OA\Property(property="enrollments.*.status", type="string", description="Rules: nullable, string, in:enrolled,pending,rejected")
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
    public function bulk(BulkEnrollmentRequest $request)
    {
        $enrollments = $this->enrollmentService->bulkCreate($request->validated(), $request->user());

        return $this->success('Enrollments created successfully.', EnrollmentResource::collection(collect($enrollments)), 201);
    }

        /**
     * @OA\Post(
     *     path="/api/admin/enrollments/bulk-upload",
     *     summary="bulkUpload action in EnrollmentController",
     *     tags={"Enrollment"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"enrollments", "enrollments.*.student_user_id", "enrollments.*.course_offering_id"},
     *             @OA\Property(property="enrollments", type="array", description="Rules: required, array, min:1"),
     *             @OA\Property(property="enrollments.*.student_user_id", type="integer", description="Rules: required, integer, exists:users,id"),
     *             @OA\Property(property="enrollments.*.course_offering_id", type="integer", description="Rules: required, integer, exists:course_offerings,id"),
     *             @OA\Property(property="enrollments.*.status", type="string", description="Rules: nullable, string, in:enrolled,pending,rejected")
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
