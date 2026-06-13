<?php

namespace App\Modules\Grades\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Academic\Infrastructure\CourseOffering;
use App\Modules\Grades\Models\StudentGrade;
use App\Modules\Grades\Requests\StoreGradeRequest;
use App\Modules\Grades\Requests\UpdateGradeRequest;
use App\Modules\Grades\Resources\GradeItemResource;
use App\Modules\Grades\Services\GradeService;
use Illuminate\Http\Request;

class GradeController extends ApiController
{
    public function __construct(protected GradeService $gradeService) {}

        /**
     * @OA\Get(
     *     path="/api/admin/courses/{courseOffering}/grades",
     *     summary="index action in GradeController",
     *     tags={"Grades"},
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
    public function index(Request $request, CourseOffering $courseOffering)
    {
        $grades = $this->gradeService->listForCourse($courseOffering, $request->integer('student_user_id'));

        return $this->success('Grades retrieved successfully.', GradeItemResource::collection($grades));
    }

    public function store(StoreGradeRequest $request, CourseOffering $courseOffering)
    {
        $grade = $this->gradeService->create($courseOffering, $request->validated(), $request->user());

        return $this->success('Grade created successfully.', GradeItemResource::make($grade), 201);
    }

        /**
     * @OA\Put(
     *     path="/api/admin/grades/{grade}",
     *     summary="update action in GradeController",
     *     tags={"Grades"},
     *     @OA\Parameter(
     *         name="grade",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The grade parameter"
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="student_user_id", type="integer", description="Rules: sometimes, integer, exists:users,id"),
     *             @OA\Property(property="type", type="string", description="Rules: sometimes, Illuminate\Validation\Rules\Enum"),
     *             @OA\Property(property="score", type="number", description="Rules: sometimes, numeric, min:0"),
     *             @OA\Property(property="max_score", type="number", description="Rules: sometimes, numeric, gt:0"),
     *             @OA\Property(property="note", type="string", description="Rules: nullable, string")
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
    public function update(UpdateGradeRequest $request, StudentGrade $grade)
    {
        $grade = $this->gradeService->update($grade, $request->validated(), $request->user());

        return $this->success('Grade updated successfully.', GradeItemResource::make($grade));
    }

    public function destroy(StudentGrade $grade)
    {
        $this->gradeService->delete($grade, request()->user());

        return $this->success('Grade deleted successfully.');
    }
}
