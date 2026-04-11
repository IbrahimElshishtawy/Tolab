<?php

namespace Database\Factories;

use App\Core\Enums\NotificationType;
use App\Modules\Notifications\Models\UserNotification;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<UserNotification>
 */
class UserNotificationFactory extends Factory
{
    protected $model = UserNotification::class;

    public function definition(): array
    {
        return [
            'target_user_id' => User::factory(),
            'title' => fake('ar_EG')->sentence(4),
            'body' => fake('ar_EG')->paragraph(),
            'type' => fake()->randomElement(NotificationType::cases()),
            'category' => 'student',
            'ref_type' => null,
            'ref_id' => null,
            'target_type' => null,
            'target_id' => null,
            'is_global' => false,
            'is_read' => false,
            'created_by' => null,
        ];
    }
}
