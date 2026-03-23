<?php

namespace App\Modules\Grades\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Grades\Resources\GradeItemResource;

class StudentGradeController extends ApiController
{
    public function index(CourseOffering $courseOffering)
    {
        $this->authorize('view', $courseOffering);

        $grades = $courseOffering->grades()
            ->where('student_user_id', request()->user()->id)
            ->latest('updated_at')
            ->get();

        return $this->success('Student grades retrieved successfully.', GradeItemResource::collection($grades));
    }
}
