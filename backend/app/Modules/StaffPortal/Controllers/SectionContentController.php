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

    public function index(Request $request)
    {
        return $this->success('Section content retrieved successfully.', SectionContentResource::collection($this->service->sectionContents($request->user())));
    }

    public function store(StoreSectionContentPortalRequest $request)
    {
        return $this->success('Section content created successfully.', SectionContentResource::make($this->service->createSectionContent($request->user(), $request->validated())), 201);
    }
}
