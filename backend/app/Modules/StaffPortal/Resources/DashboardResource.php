<?php

namespace App\Modules\StaffPortal\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DashboardResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'user' => $this['user'] ?? [],
            'quick_actions' => $this['quick_actions'] ?? [],
            'notifications' => $this['notifications'] ?? [],
            'today_stats' => $this['today_stats'] ?? [],
            'action_required' => $this['action_required'] ?? [],
            'today_schedule' => $this['today_schedule'] ?? [],
            'upcoming' => $this['upcoming'] ?? [],
            'subjects_preview' => $this['subjects_preview'] ?? [],
            'group_activity' => $this['group_activity'] ?? [],
            'student_insights' => $this['student_insights'] ?? [],
        ];
    }
}
