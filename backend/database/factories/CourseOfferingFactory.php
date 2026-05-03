<?php

namespace Database\Factories;

use App\Core\Enums\Semester;
use App\Modules\Academic\Infrastructure\CourseOffering;
use App\Modules\Academic\Infrastructure\Section;
use App\Modules\Academic\Infrastructure\Subject;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<CourseOffering>
 */
class CourseOfferingFactory extends Factory
{
    protected $model = CourseOffering::class;

    public function definition(): array
    {
        return [
            'subject_id' => Subject::factory(),
            'section_id' => Section::factory(),
            'academic_year' => '2025/2026',
            'semester' => fake()->randomElement(Semester::cases()),
            'doctor_user_id' => User::factory()->doctor(),
            'ta_user_id' => User::factory()->teachingAssistant(),
            'group_id' => null,
        ];
    }
}
