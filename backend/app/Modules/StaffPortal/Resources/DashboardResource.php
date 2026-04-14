<?php

namespace App\Modules\StaffPortal\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DashboardResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'header' => $this['header'] ?? [],
            'quick_actions' => $this['quick_actions'] ?? [],
            'action_center' => $this['action_center'] ?? [],
            'today_focus' => $this['today_focus'] ?? [],
            'timeline' => $this['timeline'] ?? [],
            'subjects_overview' => $this['subjects_overview'] ?? [],
            'students_attention' => $this['students_attention'] ?? [],
            'student_activity_insights' => $this['student_activity_insights'] ?? [],
            'course_health' => $this['course_health'] ?? [],
            'group_activity_feed' => $this['group_activity_feed'] ?? [],
            'notifications_preview' => $this['notifications_preview'] ?? [],
            'pending_grading' => $this['pending_grading'] ?? [],
            'performance_analytics' => $this['performance_analytics'] ?? [],
            'risk_alerts' => $this['risk_alerts'] ?? [],
            'weekly_summary' => $this['weekly_summary'] ?? [],
            'smart_suggestions' => $this['smart_suggestions'] ?? [],
            'user' => $this['user'] ?? ($this['header']['user'] ?? []),
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
