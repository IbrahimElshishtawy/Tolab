<?php

namespace App\Modules\Schedule\Models;

use App\Core\Enums\WeekPattern;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Schedule\Enums\ScheduleEventType;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ScheduleEvent extends Model
{
    use HasFactory;

    protected $fillable = [
        'course_offering_id',
        'type',
        'day_of_week',
        'start_time',
        'end_time',
        'location',
        'week_pattern',
        'note',
    ];

    protected function casts(): array
    {
        return [
            'type' => ScheduleEventType::class,
            'day_of_week' => 'integer',
            'week_pattern' => WeekPattern::class,
        ];
    }

    public function courseOffering(): BelongsTo
    {
        return $this->belongsTo(CourseOffering::class);
    }
}
