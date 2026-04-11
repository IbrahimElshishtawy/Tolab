<?php

namespace Database\Factories;

use App\Core\Enums\StaffTitle;
use App\Modules\Academic\Models\Department;
use App\Modules\UserManagement\Models\StaffProfile;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<StaffProfile>
 */
class StaffProfileFactory extends Factory
{
    protected $model = StaffProfile::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory()->doctor(),
            'department_id' => Department::factory(),
            'title' => fake()->randomElement(StaffTitle::cases()),
        ];
    }
}
