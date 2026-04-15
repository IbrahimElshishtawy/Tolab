<?php

namespace App\Modules\Academic\Models;

use App\Core\Enums\Semester;
use App\Modules\Content\Models\Assessment;
use App\Modules\Content\Models\CourseFile;
use App\Modules\Content\Models\Exam;
use App\Modules\Content\Models\Lecture;
use App\Modules\Content\Models\SectionSession;
use App\Modules\Content\Models\Summary;
use App\Modules\Enrollment\Models\Enrollment;
use App\Modules\Grades\Models\GradeItem;
use App\Modules\Group\Models\GroupChat;
use App\Modules\Schedule\Models\ScheduleEvent;
use App\Modules\UserManagement\Models\User;
use Database\Factories\CourseOfferingFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class CourseOffering extends Model
{
    use HasFactory;

    protected $fillable = [
        'subject_id',
        'section_id',
        'academic_year',
        'semester',
        'doctor_user_id',
        'ta_user_id',
        'group_id',
    ];

    protected function casts(): array
    {
        return [
            'semester' => Semester::class,
        ];
    }

    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    public function section(): BelongsTo
    {
        return $this->belongsTo(Section::class);
    }

    public function doctor(): BelongsTo
    {
        return $this->belongsTo(User::class, 'doctor_user_id');
    }

    public function ta(): BelongsTo
    {
        return $this->belongsTo(User::class, 'ta_user_id');
    }

    public function group(): BelongsTo
    {
        return $this->belongsTo(GroupChat::class, 'group_id');
    }

    public function groupChat(): HasOne
    {
        return $this->hasOne(GroupChat::class);
    }

    public function enrollments(): HasMany
    {
        return $this->hasMany(Enrollment::class);
    }

    public function activeEnrollments(): HasMany
    {
        return $this->enrollments()->active();
    }

    public function students(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'enrollments', 'course_offering_id', 'student_user_id')
            ->withPivot(['status'])
            ->withTimestamps();
    }

    public function lectures(): HasMany
    {
        return $this->hasMany(Lecture::class);
    }

    public function sectionSessions(): HasMany
    {
        return $this->hasMany(SectionSession::class);
    }

    public function summaries(): HasMany
    {
        return $this->hasMany(Summary::class);
    }

    public function assessments(): HasMany
    {
        return $this->hasMany(Assessment::class);
    }

    public function exams(): HasMany
    {
        return $this->hasMany(Exam::class);
    }

    public function files(): HasMany
    {
        return $this->hasMany(CourseFile::class);
    }

    public function grades(): HasMany
    {
        return $this->hasMany(GradeItem::class);
    }

    public function scheduleEvents(): HasMany
    {
        return $this->hasMany(ScheduleEvent::class);
    }

    public function scopeForStudent(Builder $query, User $student): Builder
    {
        return $query->whereHas('enrollments', fn (Builder $builder) => $builder
            ->active()
            ->where('student_user_id', $student->id));
    }

    protected static function newFactory(): CourseOfferingFactory
    {
        return CourseOfferingFactory::new();
    }
}
