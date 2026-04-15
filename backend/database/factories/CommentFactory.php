<?php

namespace Database\Factories;

use App\Modules\Group\Models\Comment;
use App\Modules\Group\Models\Post;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Comment>
 */
class CommentFactory extends Factory
{
    protected $model = Comment::class;

    public function definition(): array
    {
        return [
            'post_id' => Post::factory(),
            'author_user_id' => User::factory(),
            'text' => fake()->sentence(),
        ];
    }
}
