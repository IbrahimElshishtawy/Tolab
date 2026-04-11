<?php

namespace Database\Factories;

use App\Core\Enums\GroupMemberRole;
use App\Modules\Group\Models\GroupChat;
use App\Modules\Group\Models\GroupMember;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<GroupMember>
 */
class GroupMemberFactory extends Factory
{
    protected $model = GroupMember::class;

    public function definition(): array
    {
        return [
            'group_id' => GroupChat::factory(),
            'user_id' => User::factory(),
            'role_in_group' => GroupMemberRole::MEMBER,
        ];
    }
}
