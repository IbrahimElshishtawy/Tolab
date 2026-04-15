<?php

namespace App\Modules\Content\Models;

use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Academic\Models\Subject;
use App\Modules\Shared\Traits\HasAttachments;
use App\Modules\UserManagement\Models\User;
use Database\Factories\LectureFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class Lecture extends Model
{
    use HasAttachments;
    use HasFactory;
    use SoftDeletes;

    protected $fillable = [
        'course_offering_id',
        'subject_id',
        'created_by',
        'week_number',
        'title',
        'description',
        'instructor_name',
        'video_url',
        'file_path',
        'is_published',
        'published_at',
        'date',
    ];

    protected function casts(): array
    {
        return [
            'date' => 'date',
            'week_number' => 'integer',
            'is_published' => 'boolean',
            'published_at' => 'datetime',
        ];
    }

    public function courseOffering(): BelongsTo
    {
        return $this->belongsTo(CourseOffering::class);
    }

    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    public function author(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    protected static function newFactory(): LectureFactory
    {
        return LectureFactory::new();
    }
}
