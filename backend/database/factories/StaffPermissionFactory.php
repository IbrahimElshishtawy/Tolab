<?php

namespace Database\Factories;

use App\Modules\UserManagement\Models\StaffPermission;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<StaffPermission>
 */
class StaffPermissionFactory extends Factory
{
    protected $model = StaffPermission::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory()->teachingAssistant(),
            'can_upload_content' => true,
            'can_manage_grades' => false,
            'can_manage_schedule' => false,
            'can_moderate_group' => true,
        ];
    }
}
