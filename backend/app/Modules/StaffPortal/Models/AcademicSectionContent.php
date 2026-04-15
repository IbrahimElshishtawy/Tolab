<?php

namespace App\Modules\StaffPortal\Models;

use App\Modules\Academic\Models\Subject;
use App\Modules\UserManagement\Models\User;
use Database\Factories\AcademicSectionContentFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AcademicSectionContent extends Model
{
    use HasFactory;

    protected $fillable = [
        'subject_id',
        'created_by',
        'week_number',
        'title',
        'description',
        'assistant_name',
        'video_url',
        'meeting_url',
        'delivery_mode',
        'starts_at',
        'ends_at',
        'location_label',
        'attachment_label',
        'file_path',
        'is_published',
        'published_at',
    ];

    protected function casts(): array
    {
        return [
            'week_number' => 'integer',
            'is_published' => 'boolean',
            'starts_at' => 'datetime',
            'ends_at' => 'datetime',
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

    protected static function newFactory(): AcademicSectionContentFactory
    {
        return AcademicSectionContentFactory::new();
    }
}
