<?php

namespace App\Modules\UserManagement\Repositories;

use App\Core\Base\BaseRepository;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Builder;

class UserRepository extends BaseRepository
{
    public function __construct(User $model)
    {
        parent::__construct($model);
    }

    public function filter(array $filters): Builder
    {
        return $this->query()
            ->with(['studentProfile', 'staffProfile', 'staffPermission'])
            ->when($filters['role'] ?? null, fn (Builder $query, $role) => $query->where('role', $role))
            ->when($filters['q'] ?? null, function (Builder $query, string $q) {
                $query->where(function (Builder $inner) use ($q) {
                    $inner->where('username', 'like', "%{$q}%")
                        ->orWhere('email', 'like', "%{$q}%")
                        ->orWhere('national_id', 'like', "%{$q}%");
                });
            })
            ->when($filters['department_id'] ?? null, function (Builder $query, int $departmentId) {
                $query->where(function (Builder $inner) use ($departmentId) {
                    $inner->whereHas('studentProfile', fn (Builder $profile) => $profile->where('department_id', $departmentId))
                        ->orWhereHas('staffProfile', fn (Builder $profile) => $profile->where('department_id', $departmentId));
                });
            })
            ->when($filters['section_id'] ?? null, fn (Builder $query, int $sectionId) => $query->whereHas('studentProfile', fn (Builder $profile) => $profile->where('section_id', $sectionId)));
    }
}
