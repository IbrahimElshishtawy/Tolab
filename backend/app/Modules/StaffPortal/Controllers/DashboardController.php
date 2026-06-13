<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\StaffPortal\Resources\DashboardResource;
use App\Modules\StaffPortal\Services\DashboardService;
use Illuminate\Http\Request;

class DashboardController extends ApiController
{
    public function __construct(protected DashboardService $service) {}

        /**
     * @OA\Get(
     *     path="/api/staff-portal/dashboard",
     *     summary="index action in DashboardController",
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
        /**
     * @OA\Get(
     *     path="/api/staff/dashboard",
     *     summary="index action in DashboardController",
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
        return $this->success(
            'Dashboard loaded successfully.',
            DashboardResource::make($this->service->dashboard($request->user())),
        );
    }
}
