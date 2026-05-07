<?php

namespace App\Modules\Academic\Interface\Controllers;

use App\Core\Base\ApiController;
use App\Modules\Academic\Infrastructure\Section;
use App\Modules\Academic\Interface\Requests\StoreSectionRequest;
use App\Modules\Academic\Interface\Resources\SectionResource;
use App\Modules\Academic\Application\AcademicService;
use Illuminate\Http\Request;

class SectionController extends ApiController
{
    public function __construct(protected AcademicService $academicService) {}

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
