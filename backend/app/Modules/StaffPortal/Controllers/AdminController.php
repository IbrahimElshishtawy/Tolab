<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\StaffPortal\Services\AdminPortalService;

class AdminController extends ApiController
{
    public function __construct(protected AdminPortalService $service) {}

        /**
     * @OA\Get(
     *     path="/api/staff-portal/admin/overview",
     *     summary="overview action in AdminController",
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
    public function overview()
    {
        return $this->success('Admin overview retrieved successfully.', $this->service->overview());
    }

        /**
     * @OA\Get(
     *     path="/api/staff-portal/admin/permissions",
     *     summary="permissions action in AdminController",
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
    public function permissions()
    {
        return $this->success('Permissions retrieved successfully.', $this->service->permissions()->pluck('name')->values());
    }

        /**
     * @OA\Get(
     *     path="/api/staff-portal/admin/departments",
     *     summary="departments action in AdminController",
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
    public function departments()
    {
        return $this->success('Departments retrieved successfully.', $this->service->departments());
    }
}
