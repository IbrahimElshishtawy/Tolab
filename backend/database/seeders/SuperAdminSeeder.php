<?php

namespace Database\Seeders;

use App\Core\Enums\UserRole;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class SuperAdminSeeder extends Seeder
{
    public function run(): void
    {
        User::query()->updateOrCreate(
            ['email' => env('DEFAULT_ADMIN_EMAIL', 'admin@tolab.local')],
            [
                'role' => UserRole::ADMIN,
                'username' => 'Super Admin',
                'password_hash' => Hash::make((string) env('DEFAULT_ADMIN_PASSWORD', 'ChangeThisSuperSecurePassword123!')),
                'national_id' => null,
                'is_active' => true,
            ]
        );
    }
}
