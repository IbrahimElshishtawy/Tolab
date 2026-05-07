<?php

namespace App\Modules\Auth\Domain\Repositories;

use App\Modules\UserManagement\Models\User;

interface AuthRepositoryInterface
{
    public function findByEmail(string $email): ?User;
    public function updatePassword(User $user, string $hashedPassword): void;
}
