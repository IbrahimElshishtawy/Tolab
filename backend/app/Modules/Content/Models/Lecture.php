<?php

namespace App\Modules\Content\Models;

use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Shared\Traits\HasAttachments;
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
        'title',
        'description',
        'date',
    ];

    protected function casts(): array
    {
        return [
            'date' => 'date',
        ];
    }

    public function courseOffering(): BelongsTo
    {
        return $this->belongsTo(CourseOffering::class);
    }
}
