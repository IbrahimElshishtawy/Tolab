<?php

namespace App\Modules\Academic\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Academic\Models\Section;
use App\Modules\Academic\Requests\StoreSectionRequest;
use App\Modules\Academic\Resources\SectionResource;
use App\Modules\Academic\Services\AcademicService;
use Illuminate\Http\Request;

class SectionController extends ApiController
{
    public function __construct(protected AcademicService $academicService)
    {
    }

    public function index(Request $request)
    {
        $sections = Section::query()
            ->when($request->integer('department_id'), fn ($query, $departmentId) => $query->where('department_id', $departmentId))
            ->when($request->integer('grade_year'), fn ($query, $gradeYear) => $query->where('grade_year', $gradeYear))
            ->orderBy('name')
            ->get();

        return $this->success('Sections retrieved successfully.', SectionResource::collection($sections));
    }

    public function store(StoreSectionRequest $request)
    {
        $section = $this->academicService->createSection($request->validated(), $request->user());

        return $this->success('Section created successfully.', SectionResource::make($section), 201);
    }
}
