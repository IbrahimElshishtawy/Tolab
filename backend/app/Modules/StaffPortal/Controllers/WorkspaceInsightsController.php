<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\StaffPortal\Services\PortalService;
use Illuminate\Http\Request;

class WorkspaceInsightsController extends ApiController
{
    public function __construct(protected PortalService $service) {}

        /**
     * @OA\Get(
     *     path="/api/staff-portal/analytics/summary",
     *     summary="analytics action in WorkspaceInsightsController",
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
    public function analytics(Request $request)
    {
        return $this->success(
            'Analytics summary retrieved successfully.',
            $this->service->analyticsSummary($request->user()),
        );
    }

        /**
     * @OA\Get(
     *     path="/api/staff-portal/feed",
     *     summary="feed action in WorkspaceInsightsController",
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
    public function feed(Request $request)
    {
        return $this->success(
            'Staff feed retrieved successfully.',
            $this->service->staffFeed($request->user()),
        );
    }

        /**
     * @OA\Get(
     *     path="/api/staff-portal/schedule/conflicts",
     *     summary="conflicts action in WorkspaceInsightsController",
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
    public function conflicts(Request $request)
    {
        return $this->success(
            'Schedule conflicts retrieved successfully.',
            $this->service->scheduleConflicts($request->user()),
        );
    }

        /**
     * @OA\Get(
     *     path="/api/staff-portal/settings/control-panel",
     *     summary="controlPanelSettings action in WorkspaceInsightsController",
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
    public function controlPanelSettings(Request $request)
    {
        return $this->success(
            'Control panel settings retrieved successfully.',
            $this->service->controlPanelSettings($request->user()),
        );
    }
}
