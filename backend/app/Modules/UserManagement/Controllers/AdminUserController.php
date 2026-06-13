<?php

namespace App\Modules\UserManagement\Controllers;

use App\Core\Base\ApiController;
use App\Core\Services\PaginationSanitizer;
use App\Modules\UserManagement\Models\User;
use App\Modules\UserManagement\Requests\ResetPasswordRequest;
use App\Modules\UserManagement\Requests\StoreUserRequest;
use App\Modules\UserManagement\Requests\ToggleActivationRequest;
use App\Modules\UserManagement\Requests\UpdateUserRequest;
use App\Modules\UserManagement\Resources\UserResource;
use App\Modules\UserManagement\Services\UserService;
use Illuminate\Http\Request;

class AdminUserController extends ApiController
{
    public function __construct(
        protected UserService $userService,
        protected PaginationSanitizer $paginationSanitizer,
    ) {}

        /**
     * @OA\Get(
     *     path="/api/admin/users",
     *     summary="index action in AdminUserController",
     *     tags={"UserManagement"},
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
        $users = $this->userService->paginate($request->only(['role', 'department_id', 'section_id', 'q']), $this->paginationSanitizer->perPage($request));

        return $this->success('Users retrieved successfully.', UserResource::collection($users));
    }

    public function store(StoreUserRequest $request)
    {
        $user = $this->userService->create($request->validated(), $request->user());

        return $this->success('User created successfully.', UserResource::make($user), 201);
    }

        /**
     * @OA\Put(
     *     path="/api/admin/users/{user}",
     *     summary="update action in AdminUserController",
     *     tags={"UserManagement"},
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
     *             @OA\Property(property="role", type="string", description="Rules: sometimes, Illuminate\Validation\Rules\Enum"),
     *             @OA\Property(property="username", type="string", description="Rules: sometimes, string, max:120"),
     *             @OA\Property(property="email", type="string", description="Rules: sometimes, email:rfc,dns, max:255, Illuminate\Validation\Rules\Unique"),
     *             @OA\Property(property="password", type="string", description="Rules: nullable, string, min:8, max:255"),
     *             @OA\Property(property="national_id", type="string", description="Rules: nullable, string, max:40, Illuminate\Validation\Rules\Unique"),
     *             @OA\Property(property="is_active", type="boolean", description="Rules: sometimes, boolean"),
     *             @OA\Property(property="student_profile", type="array", description="Rules: nullable, array"),
     *             @OA\Property(property="student_profile.gpa", type="number", description="Rules: nullable, numeric, between:0,4"),
     *             @OA\Property(property="student_profile.grade_year", type="integer", description="Rules: nullable, integer, between:1,5"),
     *             @OA\Property(property="student_profile.section_id", type="integer", description="Rules: nullable, integer, exists:sections,id"),
     *             @OA\Property(property="student_profile.department_id", type="integer", description="Rules: nullable, integer, exists:departments,id"),
     *             @OA\Property(property="staff_profile", type="array", description="Rules: nullable, array"),
     *             @OA\Property(property="staff_profile.department_id", type="integer", description="Rules: nullable, integer, exists:departments,id"),
     *             @OA\Property(property="staff_profile.title", type="string", description="Rules: nullable, Illuminate\Validation\Rules\Enum"),
     *             @OA\Property(property="staff_permissions", type="array", description="Rules: nullable, array"),
     *             @OA\Property(property="staff_permissions.can_upload_content", type="boolean", description="Rules: sometimes, boolean"),
     *             @OA\Property(property="staff_permissions.can_manage_grades", type="boolean", description="Rules: sometimes, boolean"),
     *             @OA\Property(property="staff_permissions.can_manage_schedule", type="boolean", description="Rules: sometimes, boolean"),
     *             @OA\Property(property="staff_permissions.can_moderate_group", type="boolean", description="Rules: sometimes, boolean")
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
    public function update(UpdateUserRequest $request, User $user)
    {
        $user = $this->userService->update($user, $request->validated(), $request->user());

        return $this->success('User updated successfully.', UserResource::make($user));
    }

        /**
     * @OA\Patch(
     *     path="/api/admin/users/{user}/activate",
     *     summary="activate action in AdminUserController",
     *     tags={"UserManagement"},
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
    public function activate(ToggleActivationRequest $request, User $user)
    {
        $user = $this->userService->setActivation($user, $request->boolean('is_active'), $request->user());

        return $this->success('User activation updated successfully.', UserResource::make($user));
    }

        /**
     * @OA\Post(
     *     path="/api/admin/users/{user}/reset-password",
     *     summary="resetPassword action in AdminUserController",
     *     tags={"UserManagement"},
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
     *             required={"mode", "password"},
     *             @OA\Property(property="mode", type="string", description="Rules: required, Illuminate\Validation\Rules\Enum"),
     *             @OA\Property(property="password", type="string", description="Rules: required_if:mode,CUSTOM, nullable, string, min:8, max:255")
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
    public function resetPassword(ResetPasswordRequest $request, User $user)
    {
        $result = $this->userService->resetPassword($user, $request->validated(), $request->user());

        return $this->success('Password reset successfully.', $result);
    }
}
