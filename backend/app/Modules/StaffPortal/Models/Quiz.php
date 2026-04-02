<?php

namespace App\Modules\StaffPortal\Models;

use App\Modules\Academic\Models\Subject;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Quiz extends Model
{
    protected $fillable = [
        'subject_id',
        'created_by',
        'week_number',
        'title',
        'owner_name',
        'quiz_type',
        'quiz_link',
        'quiz_date',
        'is_published',
    ];

    protected function casts(): array
    {
        return [
            'week_number' => 'integer',
            'quiz_date' => 'date',
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
}
