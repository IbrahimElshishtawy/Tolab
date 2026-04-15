<?php

namespace Database\Factories;

use App\Modules\Group\Models\GroupChat;
use App\Modules\Group\Models\Message;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Message>
 */
class MessageFactory extends Factory
{
    protected $model = Message::class;

    public function definition(): array
    {
        return [
            'group_id' => GroupChat::factory(),
            'sender_user_id' => User::factory(),
            'text' => fake()->sentence(),
        ];
    }
}
