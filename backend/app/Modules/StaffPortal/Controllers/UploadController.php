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

        /**
     * @OA\Get(
     *     path="/api/staff-portal/uploads",
     *     summary="index action in UploadController",
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
        return $this->success('Uploads retrieved successfully.', UploadPortalResource::collection($this->service->uploads($request->user())));
    }

    public function store(UploadPortalRequest $request)
    {
        return $this->success('File uploaded successfully.', UploadPortalResource::make($this->service->upload($request->user(), $request->file('file'))), 201);
    }
}
