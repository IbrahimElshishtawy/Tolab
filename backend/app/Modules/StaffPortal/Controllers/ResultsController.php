<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Academic\Infrastructure\Subject;
use App\Modules\StaffPortal\Services\PortalService;
use Illuminate\Http\Request;

class ResultsController extends ApiController
{
    public function __construct(protected PortalService $service) {}

        /**
     * @OA\Get(
     *     path="/api/staff-portal/results",
     *     summary="index action in ResultsController",
     *     tags={"StaffPortal"},
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
        return $this->success('Results overview retrieved successfully.', $this->service->resultsOverview($request->user()));
    }

        /**
     * @OA\Get(
     *     path="/api/staff-portal/subjects/{subject}/results",
     *     summary="show action in ResultsController",
     *     tags={"StaffPortal"},
     *     @OA\Parameter(
     *         name="subject",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The subject parameter"
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
    public function show(Request $request, Subject $subject)
    {
        return $this->success('Subject results retrieved successfully.', $this->service->subjectResults($request->user(), $subject));
    }

        /**
     * @OA\Get(
     *     path="/api/staff-portal/subjects/{subject}/students",
     *     summary="students action in ResultsController",
     *     tags={"StaffPortal"},
     *     @OA\Parameter(
     *         name="subject",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The subject parameter"
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
    public function students(Request $request, Subject $subject)
    {
        return $this->success('Subject students retrieved successfully.', $this->service->subjectStudents($request->user(), $subject));
    }

        /**
     * @OA\Get(
     *     path="/api/staff-portal/subjects/{subject}/grading/categories",
     *     summary="categories action in ResultsController",
     *     tags={"StaffPortal"},
     *     @OA\Parameter(
     *         name="subject",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The subject parameter"
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
    public function categories(Request $request, Subject $subject)
    {
        return $this->success('Role-based grading categories retrieved successfully.', $this->service->gradingCategories($request->user(), $subject));
    }
}
