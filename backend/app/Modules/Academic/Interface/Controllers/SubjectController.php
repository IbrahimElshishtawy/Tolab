<?php

namespace App\Modules\Academic\Interface\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Academic\Infrastructure\Subject;
use App\Modules\Academic\Interface\Requests\StoreSubjectRequest;
use App\Modules\Academic\Interface\Requests\UpdateSubjectRequest;
use App\Modules\Academic\Interface\Resources\SubjectResource;
use App\Modules\Academic\Application\AcademicService;
use Illuminate\Http\Request;

class SubjectController extends ApiController
{
    public function __construct(protected AcademicService $academicService) {}

        /**
     * @OA\Get(
     *     path="/api/subjects",
     *     summary="index action in SubjectController",
     *     tags={"Academic"},
     *     @OA\Response(
     *         response=200,
     *         description="Successful operation"
     *     ),
     *     @OA\Response(response=400, ref="#/components/responses/400BadRequest")
     * )
     */
    public function index(Request $request)
    {
        $subjects = Subject::query()
            ->when($request->integer('department_id'), fn ($query, $departmentId) => $query->where('department_id', $departmentId))
            ->when($request->integer('grade_year'), fn ($query, $gradeYear) => $query->where('grade_year', $gradeYear))
            ->when($request->get('semester'), fn ($query, $semester) => $query->where('semester', $semester))
            ->orderBy('name')
            ->get();

        return $this->success('Subjects retrieved successfully.', SubjectResource::collection($subjects));
    }

        /**
     * @OA\Post(
     *     path="/api/admin/subjects",
     *     summary="store action in SubjectController",
     *     tags={"Academic"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"name", "code", "department_id", "grade_year", "semester"},
     *             @OA\Property(property="name", type="string", description="Rules: required, string, max:150"),
     *             @OA\Property(property="code", type="string", description="Rules: required, string, max:40, unique:subjects,code"),
     *             @OA\Property(property="department_id", type="integer", description="Rules: required, integer, exists:departments,id"),
     *             @OA\Property(property="grade_year", type="integer", description="Rules: required, integer, between:1,5"),
     *             @OA\Property(property="semester", type="string", description="Rules: required, Illuminate\Validation\Rules\Enum"),
     *             @OA\Property(property="is_active", type="boolean", description="Rules: sometimes, boolean")
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
    public function store(StoreSubjectRequest $request)
    {
        $subject = $this->academicService->createSubject($request->validated(), $request->user());

        return $this->success('Subject created successfully.', SubjectResource::make($subject), 201);
    }

        /**
     * @OA\Put(
     *     path="/api/admin/subjects/{subject}",
     *     summary="update action in SubjectController",
     *     tags={"Academic"},
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
     *             @OA\Property(property="name", type="string", description="Rules: sometimes, string, max:150"),
     *             @OA\Property(property="code", type="string", description="Rules: sometimes, string, max:40, Illuminate\Validation\Rules\Unique"),
     *             @OA\Property(property="department_id", type="integer", description="Rules: sometimes, integer, exists:departments,id"),
     *             @OA\Property(property="grade_year", type="integer", description="Rules: sometimes, integer, between:1,5"),
     *             @OA\Property(property="semester", type="string", description="Rules: sometimes, Illuminate\Validation\Rules\Enum"),
     *             @OA\Property(property="is_active", type="boolean", description="Rules: sometimes, boolean")
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
    public function update(UpdateSubjectRequest $request, Subject $subject)
    {
        $subject = $this->academicService->updateSubject($subject, $request->validated(), $request->user());

        return $this->success('Subject updated successfully.', SubjectResource::make($subject));
    }
}
