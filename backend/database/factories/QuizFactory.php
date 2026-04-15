<?php

namespace Database\Factories;

use App\Modules\Academic\Models\Subject;
use App\Modules\StaffPortal\Models\Quiz;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Quiz>
 */
class QuizFactory extends Factory
{
    protected $model = Quiz::class;

    public function definition(): array
    {
        $quizDate = fake()->dateTimeBetween('-2 days', '+7 days');
        $opensAt = (clone $quizDate)->modify('-1 hour');
        $closesAt = (clone $quizDate)->modify('+1 hour');

        return [
            'subject_id' => Subject::factory(),
            'created_by' => User::factory()->doctor(),
            'week_number' => fake()->numberBetween(1, 14),
            'title' => fake()->randomElement([
                'Weekly quiz',
                'Practice assessment',
                'Checkpoint quiz',
            ]),
            'description' => fake()->sentence(),
            'owner_name' => fake()->name(),
            'quiz_type' => fake()->randomElement(['online', 'offline']),
            'quiz_link' => fake()->optional()->url(),
            'quiz_date' => $quizDate,
            'opens_at' => $opensAt,
            'closes_at' => $closesAt,
            'duration_minutes' => fake()->randomElement([15, 20, 30, 45]),
            'status' => fake()->randomElement(['draft', 'published', 'closed']),
            'is_graded' => true,
            'is_practice' => false,
            'total_marks' => fake()->randomElement([10, 15, 20]),
            'questions_json' => [
                ['type' => 'mcq', 'prompt' => 'Sample question', 'marks' => 2],
            ],
            'is_published' => true,
        ];
    }
}
