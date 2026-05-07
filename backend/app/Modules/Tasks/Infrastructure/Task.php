<?php

namespace App\Modules\Tasks\Infrastructure;

use App\Modules\Academic\Infrastructure\CourseOffering;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Task extends Model
{
    use HasFactory;

    protected $fillable = [
        'course_offering_id',
        'title',
        'description',
        'due_at',
        'max_score',
        'created_by',
        'is_published',
    ];

    protected function casts(): array
    {
        return [
            'due_at' => 'datetime',
            'is_published' => 'boolean',
            'max_score' => 'decimal:2',
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

    public function submissions(): HasMany
    {
        return $this->hasMany(TaskSubmission::class);
    }
}
