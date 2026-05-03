<?php

namespace App\Modules\Auth\Infrastructure\Repositories;

use App\Modules\Auth\Domain\Repositories\AuthRepositoryInterface;
use App\Modules\UserManagement\Models\User;

class AuthRepository implements AuthRepositoryInterface
{
    public function findByEmail(string $email): ?User
    {
        $email = mb_strtolower(trim($email));

        return User::query()
            ->where(function ($query) use ($email) {
                $query->whereRaw('LOWER(email) = ?', [$email])
                    ->orWhereRaw('LOWER(university_email) = ?', [$email]);
            })
            ->first();
    }

    public function updatePassword(User $user, string $hashedPassword): void
    {
        $user->update([
            'password_hash' => $hashedPassword,
        ]);
    }
}
