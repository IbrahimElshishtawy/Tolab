<?php

namespace Database\Factories;

use App\Modules\Academic\Models\Department;
use App\Modules\Academic\Models\Section;
use App\Modules\UserManagement\Models\StudentProfile;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<StudentProfile>
 */
class StudentProfileFactory extends Factory
{
    protected $model = StudentProfile::class;

    public function definition(): array
    {
        $gradeYear = fake()->numberBetween(1, 5);

        return [
            'user_id' => User::factory(),
            'student_code' => fake()->unique()->numerify('STD#####'),
            'gpa' => fake()->randomFloat(2, 2, 4),
            'grade_year' => $gradeYear,
            'department_id' => $department = Department::factory(),
            'section_id' => Section::factory()->state(fn (array $attributes) => [
                'department_id' => $attributes['department_id'],
                'grade_year' => $attributes['grade_year'],
            ]),
        ];
    }
}
