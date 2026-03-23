<?php

namespace Database\Factories;

use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Grades\Enums\GradeType;
use App\Modules\Grades\Models\GradeItem;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<GradeItem>
 */
class GradeItemFactory extends Factory
{
    protected $model = GradeItem::class;

    public function definition(): array
    {
        return [
            'course_offering_id' => CourseOffering::factory(),
            'student_user_id' => User::factory(),
            'type' => fake()->randomElement(GradeType::cases()),
            'score' => fake()->randomFloat(2, 0, 25),
            'max_score' => 25,
            'note' => fake('ar_EG')->sentence(),
            'updated_by' => User::factory()->admin(),
        ];
    }
}
