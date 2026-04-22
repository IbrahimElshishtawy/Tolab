<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\StaffPortal\Requests\UploadPortalRequest;
use App\Modules\StaffPortal\Resources\UploadPortalResource;
use App\Modules\StaffPortal\Services\PortalService;
use Illuminate\Http\Request;

class UploadController extends ApiController
{
    public function __construct(protected PortalService $service) {}

    public function index(Request $request)
    {
        return $this->success('Uploads retrieved successfully.', UploadPortalResource::collection($this->service->uploads($request->user())));
    }

    public function store(UploadPortalRequest $request)
    {
        return $this->success('File uploaded successfully.', UploadPortalResource::make($this->service->upload($request->user(), $request->file('file'))), 201);
    }
}
