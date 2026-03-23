<?php

namespace Database\Factories;

use App\Modules\Academic\Models\Department;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Department>
 */
class DepartmentFactory extends Factory
{
    protected $model = Department::class;

    public function definition(): array
    {
        return [
            'name' => fake('ar_EG')->unique()->randomElement([
                'Computer Science',
                'Information Systems',
                'Artificial Intelligence',
                'Data Science',
            ]).' '.fake()->unique()->numberBetween(1, 500),
        ];
    }
}
