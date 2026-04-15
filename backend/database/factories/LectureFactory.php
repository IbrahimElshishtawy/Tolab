<?php

namespace Database\Factories;

use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Academic\Models\Subject;
use App\Modules\Content\Models\Lecture;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Lecture>
 */
class LectureFactory extends Factory
{
    protected $model = Lecture::class;

    public function definition(): array
    {
        return [
            'course_offering_id' => CourseOffering::factory(),
            'subject_id' => Subject::factory(),
            'created_by' => User::factory()->doctor(),
            'week_number' => fake()->numberBetween(1, 14),
            'title' => fake()->randomElement([
                'Lecture overview',
                'Weekly lecture',
                'Course session',
            ]),
            'description' => fake()->paragraph(),
            'instructor_name' => fake()->name(),
            'video_url' => fake()->optional()->url(),
            'file_path' => fake()->optional()->filePath(),
            'is_published' => true,
            'published_at' => now()->subDays(fake()->numberBetween(1, 10)),
            'date' => now()->subDays(fake()->numberBetween(1, 10))->toDateString(),
        ];
    }
}
