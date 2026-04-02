<?php

namespace App\Modules\StaffPortal\Services;

use App\Modules\Academic\Models\Department;
use App\Modules\StaffPortal\Models\Permission;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Collection;

class AdminPortalService
{
    public function overview(): array
    {
        return [
            'staff' => User::query()->whereIn('role_type', ['doctor', 'assistant'])->count(),
            'active_staff' => User::query()->whereIn('role_type', ['doctor', 'assistant'])->where('is_active', true)->count(),
            'departments' => Department::query()->count(),
            'permissions' => Permission::query()->count(),
        ];
    }

    public function staff(): Collection
    {
        return User::query()
            ->with(['staffProfile.department', 'staffAssignments.subject'])
            ->whereIn('role_type', ['doctor', 'assistant'])
            ->latest()
            ->get();
    }

    public function permissions(): Collection
    {
        return Permission::query()->orderBy('group_name')->orderBy('name')->get();
    }

    public function departments(): Collection
    {
        return Department::query()->orderBy('name')->get();
    }

    public function toggleActivation(User $user, bool $isActive): User
    {
        $user->update(['is_active' => $isActive]);

        return $user;
    }
}
