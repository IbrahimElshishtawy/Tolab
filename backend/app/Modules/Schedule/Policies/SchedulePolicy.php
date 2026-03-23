<?php

namespace App\Modules\Schedule\Policies;

use App\Modules\Schedule\Models\ScheduleEvent;
use App\Modules\UserManagement\Models\User;

class SchedulePolicy
{
    public function manage(User $user, ?ScheduleEvent $event = null): bool
    {
        return $user->isAdmin() || $user->canManageSchedule();
    }
}
