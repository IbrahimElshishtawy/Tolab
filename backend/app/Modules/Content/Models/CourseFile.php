<?php

namespace App\Modules\Content\Models;

use App\Modules\Academic\Models\CourseOffering;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class CourseFile extends Model
{
    use HasFactory;
    use SoftDeletes;

    protected $fillable = [
        'course_offering_id',
        'title',
        'file_url',
        'category',
    ];

    public function courseOffering(): BelongsTo
    {
        return $this->belongsTo(CourseOffering::class);
    }
}
