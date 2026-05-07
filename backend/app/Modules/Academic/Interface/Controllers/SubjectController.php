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

    public function store(StoreSubjectRequest $request)
    {
        $subject = $this->academicService->createSubject($request->validated(), $request->user());

        return $this->success('Subject created successfully.', SubjectResource::make($subject), 201);
    }

    public function update(UpdateSubjectRequest $request, Subject $subject)
    {
        $subject = $this->academicService->updateSubject($subject, $request->validated(), $request->user());

        return $this->success('Subject updated successfully.', SubjectResource::make($subject));
    }
}
