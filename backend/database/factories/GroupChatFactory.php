<?php

namespace Database\Factories;

use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Group\Models\GroupChat;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<GroupChat>
 */
class GroupChatFactory extends Factory
{
    protected $model = GroupChat::class;

    public function definition(): array
    {
        return [
            'course_offering_id' => CourseOffering::factory(),
            'name' => 'Course Group '.fake()->unique()->numberBetween(1, 999),
            'description' => fake('ar_EG')->sentence(),
            'created_by' => User::factory()->admin(),
        ];
    }
}
