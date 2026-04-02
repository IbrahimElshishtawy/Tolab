<?php

namespace App\Modules\Academic\Models;

use App\Core\Enums\Semester;
use App\Modules\StaffPortal\Models\AcademicYear;
use App\Modules\StaffPortal\Models\StaffAssignment;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Subject extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'code',
        'description',
        'department_id',
        'academic_year_id',
        'grade_year',
        'semester',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'grade_year' => 'integer',
            'semester' => Semester::class,
            'is_active' => 'boolean',
        ];
    }

    public function department(): BelongsTo
    {
        return $this->belongsTo(Department::class);
    }

    public function courseOfferings(): HasMany
    {
        return $this->hasMany(CourseOffering::class);
    }

    public function academicYear(): BelongsTo
    {
        return $this->belongsTo(AcademicYear::class);
    }

    public function assignments(): HasMany
    {
        return $this->hasMany(StaffAssignment::class);
    }
}
