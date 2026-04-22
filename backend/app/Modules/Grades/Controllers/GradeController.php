<?php

namespace App\Modules\Grades\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Grades\Models\GradeItem;
use App\Modules\Grades\Requests\StoreGradeRequest;
use App\Modules\Grades\Requests\UpdateGradeRequest;
use App\Modules\Grades\Resources\GradeItemResource;
use App\Modules\Grades\Services\GradeService;
use Illuminate\Http\Request;

class GradeController extends ApiController
{
    public function __construct(protected GradeService $gradeService) {}

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

    public function update(UpdateGradeRequest $request, GradeItem $grade)
    {
        $grade = $this->gradeService->update($grade, $request->validated(), $request->user());

        return $this->success('Grade updated successfully.', GradeItemResource::make($grade));
    }

    public function destroy(GradeItem $grade)
    {
        $this->gradeService->delete($grade, request()->user());

        return $this->success('Grade deleted successfully.');
    }
}
