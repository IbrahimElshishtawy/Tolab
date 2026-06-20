<?php

namespace App\Modules\Tasks\Infrastructure;

use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use App\Modules\Shared\Traits\HasAttachments;

class TaskSubmission extends Model
{
    use HasFactory, HasAttachments;

    protected $fillable = [
        'task_id',
        'student_user_id',
        'status',
        'submitted_at',
        'graded_at',
        'score',
        'feedback',
    ];

    protected function casts(): array
    {
        return [
            'submitted_at' => 'datetime',
            'graded_at' => 'datetime',
            'score' => 'decimal:2',
        ];
    }

    public function task(): BelongsTo
    {
        return $this->belongsTo(Task::class);
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(User::class, 'student_user_id');
    }

    protected static function newFactory(): \Database\Factories\TaskSubmissionFactory
    {
        return \Database\Factories\TaskSubmissionFactory::new();
    }
}

