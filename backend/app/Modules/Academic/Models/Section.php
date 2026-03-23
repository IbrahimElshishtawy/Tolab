<?php

namespace App\Modules\Academic\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Section extends Model
{
    use HasFactory;

    protected $fillable = ['name', 'grade_year', 'department_id'];

    protected function casts(): array
    {
        return [
            'grade_year' => 'integer',
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
