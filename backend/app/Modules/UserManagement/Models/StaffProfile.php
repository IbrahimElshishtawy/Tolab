<?php

namespace App\Modules\UserManagement\Models;

use App\Core\Enums\StaffTitle;
use App\Modules\Academic\Models\Department;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StaffProfile extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'department_id',
        'title',
    ];

    protected function casts(): array
    {
        return [
            'title' => StaffTitle::class,
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function department(): BelongsTo
    {
        return $this->belongsTo(Department::class);
    }
}
