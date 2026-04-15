<?php

namespace Database\Factories;

use App\Modules\StaffPortal\Models\AcademicYear;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<AcademicYear>
 */
class AcademicYearFactory extends Factory
{
    protected $model = AcademicYear::class;

    public function definition(): array
    {
        $level = fake()->numberBetween(1, 5);

        return [
            'name' => sprintf('Level %d - 2025/2026', $level),
            'level' => $level,
            'is_active' => true,
        ];
    }
}
