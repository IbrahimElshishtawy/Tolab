<?php

namespace App\Modules\Grades\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Academic\Infrastructure\CourseOffering;
use App\Modules\Grades\Resources\GradeItemResource;

class StudentGradeController extends ApiController
{
        /**
     * @OA\Get(
     *     path="/api/student/courses/{courseOffering}/grades",
     *     summary="index action in StudentGradeController",
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
    public function index(CourseOffering $courseOffering)
    {
        $this->authorize('view', $courseOffering);

        $grades = $courseOffering->grades()
            ->with(['gradeCategory', 'student', 'grader:id,username,full_name'])
            ->whereHas('student', fn($q) => $q->where('user_id', request()->user()->id))
            ->latest('updated_at')
            ->get();

        return $this->success('Student grades retrieved successfully.', GradeItemResource::collection($grades));
    }
}
