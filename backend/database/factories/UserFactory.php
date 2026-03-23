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
        return [
            'role' => UserRole::STUDENT,
            'username' => fake('ar_EG')->name(),
            'email' => fake()->unique()->safeEmail(),
            'password_hash' => Hash::make('password123'),
            'national_id' => fake()->unique()->numerify('##############'),
            'is_active' => true,
            'remember_token' => Str::random(10),
        ];
    }

    public function admin(): static
    {
        return $this->state(fn () => [
            'role' => UserRole::ADMIN,
            'national_id' => null,
        ]);
    }

    public function doctor(): static
    {
        return $this->state(fn () => [
            'role' => UserRole::DOCTOR,
            'national_id' => null,
        ]);
    }

    public function teachingAssistant(): static
    {
        return $this->state(fn () => [
            'role' => UserRole::TA,
            'national_id' => null,
        ]);
    }
}
