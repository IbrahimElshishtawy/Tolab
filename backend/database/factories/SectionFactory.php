<?php

namespace Database\Factories;

use App\Modules\Academic\Models\Department;
use App\Modules\Academic\Models\Section;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Section>
 */
class SectionFactory extends Factory
{
    protected $model = Section::class;

    public function definition(): array
    {
        return [
            'name' => 'Section '.fake()->unique()->numberBetween(1, 99),
            'grade_year' => fake()->numberBetween(1, 5),
            'department_id' => Department::factory(),
        ];
    }
}
