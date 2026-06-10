<?php

namespace App\Modules\Grades\Models;

use App\Modules\Academic\Infrastructure\Subject;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UploadedGradeSheet extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $fillable = [
        'subject_id',
        'grade_category_id',
        'file_name',
        'file_url',
        'mime_type',
        'file_size_bytes',
        'uploaded_by',
        'created_at',
    ];

    protected static function booted()
    {
        static::creating(function ($model) {
            $model->created_at = $model->freshTimestamp();
        });
    }

    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    public function gradeCategory(): BelongsTo
    {
        return $this->belongsTo(GradeCategory::class);
    }

    public function uploader(): BelongsTo
    {
        return $this->belongsTo(User::class, 'uploaded_by');
    }
}
