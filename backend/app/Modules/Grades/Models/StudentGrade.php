<?php

namespace App\Modules\Grades\Models;

use App\Modules\UserManagement\Models\StudentProfile;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StudentGrade extends Model
{
    use HasFactory;

    protected $fillable = [
        'student_id',
        'grade_category_id',
        'score',
        'status',
        'note',
        'graded_by',
    ];

    protected function casts(): array
    {
        return [
            'score' => 'decimal:2',
        ];
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(StudentProfile::class, 'student_id');
    }

    public function gradeCategory(): BelongsTo
    {
        return $this->belongsTo(GradeCategory::class);
    }

    public function grader(): BelongsTo
    {
        return $this->belongsTo(User::class, 'graded_by');
    }
}
