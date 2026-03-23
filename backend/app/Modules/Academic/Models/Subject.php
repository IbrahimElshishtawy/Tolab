<?php

namespace App\Modules\Academic\Models;

use App\Core\Enums\Semester;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Subject extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'code',
        'department_id',
        'grade_year',
        'semester',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'grade_year' => 'integer',
            'semester' => Semester::class,
            'is_active' => 'boolean',
        ];
    }

    public function department(): BelongsTo
    {
        return $this->belongsTo(Department::class);
    }

    public function courseOfferings(): HasMany
    {
        return $this->hasMany(CourseOffering::class);
    }
}
