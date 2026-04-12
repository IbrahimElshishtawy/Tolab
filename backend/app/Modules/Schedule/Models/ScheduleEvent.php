<?php

namespace App\Modules\Schedule\Models;

use App\Core\Enums\WeekPattern;
use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Academic\Models\Department;
use App\Modules\Academic\Models\Subject;
use App\Modules\Schedule\Enums\ScheduleEventType;
use App\Modules\StaffPortal\Models\AcademicYear;
use App\Modules\UserManagement\Models\User;
use Carbon\CarbonImmutable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ScheduleEvent extends Model
{
    use HasFactory;

    protected $fillable = [
        'course_offering_id',
        'subject_id',
        'department_id',
        'academic_year_id',
        'staff_user_id',
        'type',
        'event_type',
        'title',
        'description',
        'event_date',
        'day_of_week',
        'start_time',
        'end_time',
        'location',
        'week_pattern',
        'color_key',
        'is_completed',
        'note',
    ];

    protected function casts(): array
    {
        return [
            'type' => ScheduleEventType::class,
            'event_date' => 'date',
            'day_of_week' => 'integer',
            'week_pattern' => WeekPattern::class,
            'is_completed' => 'boolean',
        ];
    }

    public function courseOffering(): BelongsTo
    {
        return $this->belongsTo(CourseOffering::class);
    }

    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    public function department(): BelongsTo
    {
        return $this->belongsTo(Department::class);
    }

    public function academicYear(): BelongsTo
    {
        return $this->belongsTo(AcademicYear::class);
    }

    public function staffUser(): BelongsTo
    {
        return $this->belongsTo(User::class, 'staff_user_id');
    }

    public function resolveStartAt(): CarbonImmutable
    {
        return $this->resolveDateTime($this->start_time);
    }

    public function resolveEndAt(): CarbonImmutable
    {
        $endAt = $this->resolveDateTime($this->end_time);

        if ($endAt->lessThanOrEqualTo($this->resolveStartAt())) {
            return $endAt->addDay();
        }

        return $endAt;
    }

    public function resolveComputedStatus(): string
    {
        return $this->resolveEndAt()->isPast() ? 'completed' : 'planned';
    }

    protected function resolveDateTime(string $time): CarbonImmutable
    {
        $reference = CarbonImmutable::now()->startOfWeek(CarbonImmutable::SUNDAY)
            ->addDays($this->day_of_week ?? 0);
        [$hour, $minute] = array_pad(explode(':', $time), 2, '0');

        return $reference->setTime((int) $hour, (int) $minute);
    }
}
