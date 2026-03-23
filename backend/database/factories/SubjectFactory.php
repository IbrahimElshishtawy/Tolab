<?php

namespace Database\Factories;

use App\Core\Enums\Semester;
use App\Modules\Academic\Models\Department;
use App\Modules\Academic\Models\Subject;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Subject>
 */
class SubjectFactory extends Factory
{
    protected $model = Subject::class;

    public function definition(): array
    {
        return [
            'name' => fake('ar_EG')->randomElement([
                'Data Structures',
                'Database Systems',
                'Operating Systems',
                'Machine Learning',
            ]),
            'code' => strtoupper(fake()->unique()->bothify('SUB###')),
            'department_id' => Department::factory(),
            'grade_year' => fake()->numberBetween(1, 5),
            'semester' => fake()->randomElement(Semester::cases()),
            'is_active' => true,
        ];
    }
}
