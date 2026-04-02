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
            ['email' => env('DEFAULT_ADMIN_EMAIL', 'admin@tolab.edu')],
            [
                'role' => UserRole::ADMIN,
                'username' => 'Super Admin',
                'full_name' => 'Super Admin',
                'university_email' => env('DEFAULT_ADMIN_EMAIL', 'admin@tolab.edu'),
                'role_type' => 'admin',
                'password_hash' => Hash::make((string) env('DEFAULT_ADMIN_PASSWORD', 'Admin@123')),
                'national_id' => null,
                'is_active' => true,
            ]
        );
    }
}
