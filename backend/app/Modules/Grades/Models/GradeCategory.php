<?php

namespace App\Modules\Grades\Models;

use App\Modules\Academic\Infrastructure\Subject;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class GradeCategory extends Model
{
    use HasFactory;

    protected $fillable = [
        'subject_id',
        'key_name',
        'label',
        'max_score',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'max_score' => 'decimal:2',
        ];
    }

    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    public function studentGrades(): HasMany
    {
        return $this->hasMany(StudentGrade::class, 'grade_category_id');
    }

    public function uploadedGradeSheets(): HasMany
    {
        return $this->hasMany(UploadedGradeSheet::class, 'grade_category_id');
    }
}
