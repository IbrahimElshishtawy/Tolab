<?php

namespace App\Modules\StaffPortal\Models;

use App\Modules\Academic\Models\Subject;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AcademicSectionContent extends Model
{
    protected $fillable = [
        'subject_id',
        'created_by',
        'week_number',
        'title',
        'assistant_name',
        'video_url',
        'file_path',
        'is_published',
        'published_at',
    ];

    protected function casts(): array
    {
        return [
            'week_number' => 'integer',
            'is_published' => 'boolean',
            'published_at' => 'datetime',
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
