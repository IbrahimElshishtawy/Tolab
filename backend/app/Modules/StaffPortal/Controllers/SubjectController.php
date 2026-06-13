<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Academic\Infrastructure\Subject;
use App\Modules\StaffPortal\Resources\SubjectPortalResource;
use App\Modules\StaffPortal\Services\PortalService;
use Illuminate\Http\Request;

class SubjectController extends ApiController
{
    public function __construct(protected PortalService $service) {}

        /**
     * @OA\Get(
     *     path="/api/staff-portal/subjects",
     *     summary="index action in SubjectController",
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
        return $this->success('Subjects retrieved successfully.', SubjectPortalResource::collection($this->service->subjects($request->user())));
    }

        /**
     * @OA\Get(
     *     path="/api/staff-portal/subjects/{subject}",
     *     summary="show action in SubjectController",
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
        return $this->success('Subject retrieved successfully.', SubjectPortalResource::make($this->service->subject($request->user(), $subject)));
    }

        /**
     * @OA\Get(
     *     path="/api/staff-portal/subjects/{subject}/workspace",
     *     summary="workspace action in SubjectController",
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
    public function workspace(Request $request, Subject $subject)
    {
        return $this->success('Subject workspace retrieved successfully.', $this->service->subjectWorkspace($request->user(), $subject));
    }
}
