<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\StaffPortal\Requests\UpdatePortalSettingsRequest;
use App\Modules\StaffPortal\Resources\SessionUserResource;
use App\Modules\StaffPortal\Services\PortalService;
use Illuminate\Http\Request;

class ProfileController extends ApiController
{
    public function __construct(protected PortalService $service) {}

        /**
     * @OA\Get(
     *     path="/api/staff-portal/profile",
     *     summary="show action in ProfileController",
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
    public function show(Request $request)
    {
        return $this->success('Profile retrieved successfully.', SessionUserResource::make($this->service->profile($request->user())));
    }

        /**
     * @OA\Put(
     *     path="/api/staff-portal/profile/settings",
     *     summary="updateSettings action in ProfileController",
     *     tags={"StaffPortal"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             @OA\Property(property="language", type="string", description="Rules: nullable, string, max:10"),
     *             @OA\Property(property="notification_enabled", type="boolean", description="Rules: nullable, boolean"),
     *             @OA\Property(property="phone", type="string", description="Rules: nullable, string, max:40")
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
    public function updateSettings(UpdatePortalSettingsRequest $request)
    {
        return $this->success('Settings updated successfully.', SessionUserResource::make($this->service->updateSettings($request->user(), $request->validated())));
    }
}
