<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\StaffPortal\Requests\StoreSectionContentPortalRequest;
use App\Modules\StaffPortal\Resources\SectionContentResource;
use App\Modules\StaffPortal\Services\PortalService;
use Illuminate\Http\Request;

class SectionContentController extends ApiController
{
    public function __construct(protected PortalService $service) {}

        /**
     * @OA\Get(
     *     path="/api/staff-portal/section-content",
     *     summary="index action in SectionContentController",
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
        return $this->success('Section content retrieved successfully.', SectionContentResource::collection($this->service->sectionContents($request->user())));
    }

    public function store(StoreSectionContentPortalRequest $request)
    {
        return $this->success('Section content created successfully.', SectionContentResource::make($this->service->createSectionContent($request->user(), $request->validated())), 201);
    }
}
