<?php

namespace App\Modules\UserManagement\Models;

use App\Modules\Academic\Infrastructure\Department;
use App\Modules\Academic\Infrastructure\Section;
use Database\Factories\StudentProfileFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StudentProfile extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'student_code',
        'gpa',
        'grade_year',
        'section_id',
        'department_id',
    ];

    protected function casts(): array
    {
        return [
            'gpa' => 'decimal:2',
            'grade_year' => 'integer',
        ];
    }

    protected static function newFactory(): StudentProfileFactory
    {
        return StudentProfileFactory::new();
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function section(): BelongsTo
    {
        return $this->belongsTo(Section::class);
    }

    public function department(): BelongsTo
    {
        return $this->belongsTo(Department::class);
    }

    public function studentGrades(): HasMany
    {
        return $this->hasMany(\App\Modules\Grades\Models\StudentGrade::class, 'student_id');
    }
}
