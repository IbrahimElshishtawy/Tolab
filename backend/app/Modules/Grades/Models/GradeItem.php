<?php

namespace App\Modules\Grades\Models;

use App\Modules\Academic\Models\CourseOffering;
use App\Modules\Grades\Enums\GradeType;
use App\Modules\UserManagement\Models\User;
use Database\Factories\GradeItemFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class GradeItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'course_offering_id',
        'student_user_id',
        'type',
        'score',
        'max_score',
        'status',
        'published_at',
        'entered_by_role',
        'note',
        'updated_by',
    ];

    protected function casts(): array
    {
        return [
            'type' => GradeType::class,
            'score' => 'decimal:2',
            'max_score' => 'decimal:2',
            'published_at' => 'datetime',
        ];
    }

    public function courseOffering(): BelongsTo
    {
        return $this->belongsTo(CourseOffering::class);
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(User::class, 'student_user_id');
    }

    public function updater(): BelongsTo
    {
        return $this->belongsTo(User::class, 'updated_by');
    }

    protected static function newFactory(): GradeItemFactory
    {
        return GradeItemFactory::new();
    }
}
