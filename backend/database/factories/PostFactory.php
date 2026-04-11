<?php

namespace Database\Factories;

use App\Modules\Group\Models\GroupChat;
use App\Modules\Group\Models\Post;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Post>
 */
class PostFactory extends Factory
{
    protected $model = Post::class;

    public function definition(): array
    {
        return [
            'group_id' => GroupChat::factory(),
            'author_user_id' => User::factory(),
            'content_text' => fake('ar_EG')->paragraph(),
        ];
    }
}
