<?php

namespace App\Modules\UserManagement\Models;

use App\Modules\Academic\Models\Department;
use App\Modules\Academic\Models\Section;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StudentProfile extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'gpa',
        'grade_year',
        'section_id',
        'department_id',
    ];

    protected function casts(): array
    {
        return [
            'gpa' => 'decimal:2',
            'grade_year' => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function section(): BelongsTo
    {
        return $this->belongsTo(Section::class);
    }

    public function department(): BelongsTo
    {
        return $this->belongsTo(Department::class);
    }
}
