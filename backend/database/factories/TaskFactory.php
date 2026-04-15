<?php

namespace Database\Factories;

use App\Modules\Academic\Models\Subject;
use App\Modules\StaffPortal\Models\Task;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Task>
 */
class TaskFactory extends Factory
{
    protected $model = Task::class;

    public function definition(): array
    {
        return [
            'subject_id' => Subject::factory(),
            'created_by' => User::factory()->doctor(),
            'week_number' => fake()->numberBetween(1, 14),
            'title' => fake()->randomElement([
                'Weekly task',
                'Lab submission',
                'Project checkpoint',
            ]),
            'lecture_or_section_name' => fake()->randomElement(['Lecture', 'Section', 'Lab']),
            'owner_name' => fake()->name(),
            'file_path' => fake()->optional()->filePath(),
            'due_date' => fake()->dateTimeBetween('-3 days', '+7 days'),
            'is_published' => true,
        ];
    }
}
