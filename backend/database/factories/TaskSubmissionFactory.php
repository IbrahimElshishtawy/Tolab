<?php

namespace Database\Factories;

use App\Modules\Tasks\Infrastructure\Task;
use App\Modules\Tasks\Infrastructure\TaskSubmission;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<TaskSubmission>
 */
class TaskSubmissionFactory extends Factory
{
    protected $model = TaskSubmission::class;

    public function definition(): array
    {
        $submittedAt = fake()->dateTimeBetween('-3 days', 'now');

        return [
            'task_id' => Task::factory(),
            'student_user_id' => User::factory(),
            'status' => 'submitted',
            'submitted_at' => $submittedAt,
            'graded_at' => fake()->optional()->dateTimeBetween($submittedAt, 'now'),
            'score' => fake()->optional()->randomFloat(2, 5, 20),
            'feedback' => fake()->optional()->sentence(),
        ];
    }
}
