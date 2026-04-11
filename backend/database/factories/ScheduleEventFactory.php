<?php

namespace Database\Factories;

use App\Core\Enums\WeekPattern;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Schedule\Enums\ScheduleEventType;
use App\Modules\Schedule\Models\ScheduleEvent;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<ScheduleEvent>
 */
class ScheduleEventFactory extends Factory
{
    protected $model = ScheduleEvent::class;

    public function definition(): array
    {
        return [
            'course_offering_id' => CourseOffering::factory(),
            'type' => fake()->randomElement(ScheduleEventType::cases()),
            'day_of_week' => fake()->numberBetween(0, 6),
            'start_time' => '09:00:00',
            'end_time' => '11:00:00',
            'location' => 'Hall '.fake()->numberBetween(1, 10),
            'week_pattern' => fake()->randomElement(WeekPattern::cases()),
            'note' => fake('ar_EG')->sentence(),
        ];
    }
}
