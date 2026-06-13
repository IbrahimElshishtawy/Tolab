<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Academic\Infrastructure\Subject;
use App\Modules\StaffPortal\Requests\SaveSubjectGradesRequest;
use App\Modules\StaffPortal\Services\PortalService;

class GradeManagementController extends ApiController
{
    public function __construct(protected PortalService $service) {}

        /**
     * @OA\Post(
     *     path="/api/staff-portal/subjects/{subject}/grades/draft",
     *     summary="saveDraft action in GradeManagementController",
     *     tags={"StaffPortal"},
     *     @OA\Parameter(
     *         name="subject",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The subject parameter"
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"category_key", "max_score", "entries", "entries.*.student_code"},
     *             @OA\Property(property="category_key", type="string", description="Rules: required, string, max:40"),
     *             @OA\Property(property="max_score", type="number", description="Rules: required, numeric, min:0, max:1000"),
     *             @OA\Property(property="entries", type="array", description="Rules: required, array, min:1"),
     *             @OA\Property(property="entries.*.student_code", type="string", description="Rules: required, string, max:40"),
     *             @OA\Property(property="entries.*.score", type="number", description="Rules: nullable, numeric, min:0, max:1000"),
     *             @OA\Property(property="entries.*.note", type="string", description="Rules: nullable, string, max:1000")
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
    public function saveDraft(SaveSubjectGradesRequest $request, Subject $subject)
    {
        return $this->success('Grades draft saved successfully.', $this->service->saveSubjectGrades($request->user(), $subject, $request->validated(), false));
    }

        /**
     * @OA\Post(
     *     path="/api/staff-portal/subjects/{subject}/grades/publish",
     *     summary="publish action in GradeManagementController",
     *     tags={"StaffPortal"},
     *     @OA\Parameter(
     *         name="subject",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The subject parameter"
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"category_key", "max_score", "entries", "entries.*.student_code"},
     *             @OA\Property(property="category_key", type="string", description="Rules: required, string, max:40"),
     *             @OA\Property(property="max_score", type="number", description="Rules: required, numeric, min:0, max:1000"),
     *             @OA\Property(property="entries", type="array", description="Rules: required, array, min:1"),
     *             @OA\Property(property="entries.*.student_code", type="string", description="Rules: required, string, max:40"),
     *             @OA\Property(property="entries.*.score", type="number", description="Rules: nullable, numeric, min:0, max:1000"),
     *             @OA\Property(property="entries.*.note", type="string", description="Rules: nullable, string, max:1000")
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
    public function publish(SaveSubjectGradesRequest $request, Subject $subject)
    {
        return $this->success('Grades published successfully.', $this->service->saveSubjectGrades($request->user(), $subject, $request->validated(), true));
    }
}
