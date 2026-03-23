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
    ) {
    }

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

    public function update(UpdateUserRequest $request, User $user)
    {
        $user = $this->userService->update($user, $request->validated(), $request->user());

        return $this->success('User updated successfully.', UserResource::make($user));
    }

    public function activate(ToggleActivationRequest $request, User $user)
    {
        $user = $this->userService->setActivation($user, $request->boolean('is_active'), $request->user());

        return $this->success('User activation updated successfully.', UserResource::make($user));
    }

    public function resetPassword(ResetPasswordRequest $request, User $user)
    {
        $result = $this->userService->resetPassword($user, $request->validated(), $request->user());

        return $this->success('Password reset successfully.', $result);
    }
}
