<?php

namespace App\Modules\StaffPortal\Models;

use App\Modules\Academic\Models\Subject;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Task extends Model
{
    protected $fillable = [
        'subject_id',
        'created_by',
        'week_number',
        'title',
        'lecture_or_section_name',
        'owner_name',
        'file_path',
        'due_date',
        'is_published',
    ];

    protected function casts(): array
    {
        return [
            'week_number' => 'integer',
            'due_date' => 'date',
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
