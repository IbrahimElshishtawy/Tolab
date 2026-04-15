<?php

namespace Database\Factories;

use App\Modules\Academic\Models\Department;
use App\Modules\Academic\Models\Section;
use App\Modules\Academic\Models\Subject;
use App\Modules\StaffPortal\Models\AcademicYear;
use App\Modules\StaffPortal\Models\StaffAssignment;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<StaffAssignment>
 */
class StaffAssignmentFactory extends Factory
{
    protected $model = StaffAssignment::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory()->doctor(),
            'subject_id' => Subject::factory(),
            'section_id' => Section::factory(),
            'department_id' => Department::factory(),
            'academic_year_id' => AcademicYear::factory(),
            'assignment_type' => fake()->randomElement(['doctor', 'assistant']),
        ];
    }
}
