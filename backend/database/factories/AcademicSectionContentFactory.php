<?php

namespace Database\Factories;

use App\Modules\Academic\Models\Subject;
use App\Modules\StaffPortal\Models\AcademicSectionContent;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<AcademicSectionContent>
 */
class AcademicSectionContentFactory extends Factory
{
    protected $model = AcademicSectionContent::class;

    public function definition(): array
    {
        $startsAt = fake()->dateTimeBetween('-3 days', '+5 days');

        return [
            'subject_id' => Subject::factory(),
            'created_by' => User::factory()->teachingAssistant(),
            'week_number' => fake()->numberBetween(1, 14),
            'title' => fake()->randomElement([
                'Lab walkthrough',
                'Section worksheet',
                'Hands-on session',
            ]),
            'description' => fake()->sentence(),
            'assistant_name' => fake()->name(),
            'video_url' => fake()->optional()->url(),
            'meeting_url' => fake()->optional()->url(),
            'delivery_mode' => fake()->randomElement(['online', 'hybrid', 'onsite']),
            'starts_at' => $startsAt,
            'ends_at' => (clone $startsAt)->modify('+90 minutes'),
            'location_label' => fake()->optional()->randomElement(['Lab 2', 'Lab 5', 'Room B204']),
            'attachment_label' => fake()->optional()->randomElement(['Worksheet PDF', 'Slides', 'Starter Files']),
            'file_path' => fake()->optional()->filePath(),
            'is_published' => true,
            'published_at' => now()->subDays(fake()->numberBetween(1, 7)),
        ];
    }
}
