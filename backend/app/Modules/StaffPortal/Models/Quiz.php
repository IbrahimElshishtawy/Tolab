<?php

namespace App\Modules\StaffPortal\Models;

use App\Modules\Academic\Models\Subject;
use App\Modules\UserManagement\Models\User;
use Database\Factories\QuizFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Quiz extends Model
{
    use HasFactory;

    protected $fillable = [
        'subject_id',
        'created_by',
        'week_number',
        'title',
        'description',
        'owner_name',
        'quiz_type',
        'quiz_link',
        'quiz_date',
        'opens_at',
        'closes_at',
        'duration_minutes',
        'status',
        'is_graded',
        'is_practice',
        'total_marks',
        'questions_json',
        'is_published',
    ];

    protected function casts(): array
    {
        return [
            'week_number' => 'integer',
            'quiz_date' => 'date',
            'opens_at' => 'datetime',
            'closes_at' => 'datetime',
            'duration_minutes' => 'integer',
            'is_graded' => 'boolean',
            'is_practice' => 'boolean',
            'total_marks' => 'integer',
            'questions_json' => 'array',
            'is_published' => 'boolean',
        ];
    }

    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    public function author(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    protected static function newFactory(): QuizFactory
    {
        return QuizFactory::new();
    }
}
