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

        /**
     * @OA\Get(
     *     path="/api/sections",
     *     summary="index action in SectionController",
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
        $sections = Section::query()
            ->when($request->integer('department_id'), fn ($query, $departmentId) => $query->where('department_id', $departmentId))
            ->when($request->integer('grade_year'), fn ($query, $gradeYear) => $query->where('grade_year', $gradeYear))
            ->orderBy('name')
            ->get();

        return $this->success('Sections retrieved successfully.', SectionResource::collection($sections));
    }

        /**
     * @OA\Post(
     *     path="/api/admin/sections",
     *     summary="store action in SectionController",
     *     tags={"Academic"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"name", "grade_year", "department_id"},
     *             @OA\Property(property="name", type="string", description="Rules: required, string, max:150"),
     *             @OA\Property(property="grade_year", type="integer", description="Rules: required, integer, between:1,5"),
     *             @OA\Property(property="department_id", type="integer", description="Rules: required, integer, exists:departments,id")
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
    public function store(StoreSectionRequest $request)
    {
        $section = $this->academicService->createSection($request->validated(), $request->user());

        return $this->success('Section created successfully.', SectionResource::make($section), 201);
    }
}
