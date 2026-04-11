<?php

namespace Database\Factories;

use App\Core\Enums\UserRole;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * @extends Factory<User>
 */
class UserFactory extends Factory
{
    protected $model = User::class;

    public function definition(): array
    {
        $email = fake()->unique()->safeEmail();

        return [
            'role' => UserRole::STUDENT,
            'role_type' => 'student',
            'username' => $name = fake('ar_EG')->name(),
            'full_name' => $name,
            'email' => $email,
            'university_email' => $email,
            'password_hash' => Hash::make('password123'),
            'national_id' => fake()->unique()->numerify('##############'),
            'is_active' => true,
            'is_microsoft_linked' => false,
            'remember_token' => Str::random(10),
        ];
    }

    public function admin(): static
    {
        return $this->state(fn () => [
            'role' => UserRole::ADMIN,
            'role_type' => 'admin',
            'national_id' => null,
        ]);
    }

    public function doctor(): static
    {
        return $this->state(fn () => [
            'role' => UserRole::DOCTOR,
            'role_type' => 'doctor',
            'national_id' => null,
        ]);
    }

    public function teachingAssistant(): static
    {
        return $this->state(fn () => [
            'role' => UserRole::TA,
            'role_type' => 'assistant',
            'national_id' => null,
        ]);
    }
}
