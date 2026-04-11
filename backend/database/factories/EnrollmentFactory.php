<?php

namespace Database\Factories;

use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Enrollment\Models\Enrollment;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Enrollment>
 */
class EnrollmentFactory extends Factory
{
    protected $model = Enrollment::class;

    public function definition(): array
    {
        return [
            'student_user_id' => User::factory(),
            'course_offering_id' => CourseOffering::factory(),
            'status' => Enrollment::STATUS_ENROLLED,
        ];
    }
}
