<?php

namespace App\Modules\Content\Models;

use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Shared\Traits\HasAttachments;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class Exam extends Model
{
    use HasAttachments;
    use HasFactory;
    use SoftDeletes;

    protected $fillable = [
        'course_offering_id',
        'title',
        'exam_at',
        'created_by',
    ];

    protected function casts(): array
    {
        return [
            'exam_at' => 'datetime',
        ];
    }

    public function courseOffering(): BelongsTo
    {
        return $this->belongsTo(CourseOffering::class);
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }
}
