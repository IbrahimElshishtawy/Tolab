<?php

namespace App\Modules\StaffPortal\Controllers;

use App\Core\Base\ApiController;
use App\Modules\StaffPortal\Requests\TogglePortalStaffActivationRequest;
use App\Modules\StaffPortal\Resources\StaffMemberResource;
use App\Modules\StaffPortal\Services\AdminPortalService;
use App\Modules\UserManagement\Models\User;

class StaffController extends ApiController
{
    public function __construct(protected AdminPortalService $service) {}

        /**
     * @OA\Get(
     *     path="/api/staff-portal/admin/staff",
     *     summary="index action in StaffController",
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
    public function index()
    {
        return $this->success('Staff retrieved successfully.', StaffMemberResource::collection($this->service->staff()));
    }

        /**
     * @OA\Patch(
     *     path="/api/staff-portal/admin/staff/{user}/activation",
     *     summary="toggleActivation action in StaffController",
     *     tags={"StaffPortal"},
     *     @OA\Parameter(
     *         name="user",
     *         in="path",
     *         required=true,
     *         @OA\Schema(type="string"),
     *         description="The user parameter"
     *     ),
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             type="object",
     *             required={"is_active"},
     *             @OA\Property(property="is_active", type="boolean", description="Rules: required, boolean")
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
    public function toggleActivation(TogglePortalStaffActivationRequest $request, User $user)
    {
        return $this->success('Staff activation updated successfully.', StaffMemberResource::make($this->service->toggleActivation($user, $request->boolean('is_active'))));
    }
}
