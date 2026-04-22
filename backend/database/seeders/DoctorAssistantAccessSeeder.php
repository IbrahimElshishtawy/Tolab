<?php

namespace Database\Seeders;

use App\Core\Enums\UserRole;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Seeder;

class DoctorAssistantAccessSeeder extends Seeder
{
    public function run(): void
    {
        $password = (string) env('DEFAULT_STAFF_PASSWORD', env('DEFAULT_ACADEMY_PASSWORD', '123456'));

        User::query()->updateOrCreate(
            ['email' => 'doctor@tolab.edu'],
            [
                'role' => UserRole::DOCTOR,
                'role_type' => 'doctor',
                'username' => 'dr.ahmed.hassan',
                'full_name' => 'Dr. Ahmed Hassan',
                'university_email' => 'doctor@tolab.edu',
                'password_hash' => $password,
                'is_active' => true,
            ],
        );

        User::query()->updateOrCreate(
            ['email' => 'assistant@tolab.edu'],
            [
                'role' => UserRole::TA,
                'role_type' => 'assistant',
                'username' => 'ta.sara.ali',
                'full_name' => 'Sara Ali',
                'university_email' => 'assistant@tolab.edu',
                'password_hash' => $password,
                'is_active' => true,
            ],
        );
    }
}
