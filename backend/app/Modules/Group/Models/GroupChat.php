<?php

namespace App\Modules\Group\Models;

use App\Modules\Academic\Models\CourseOffering;
use App\Modules\UserManagement\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class GroupChat extends Model
{
    use HasFactory;

    protected $fillable = [
        'course_offering_id',
        'name',
        'description',
        'created_by',
    ];

    public function courseOffering(): BelongsTo
    {
        return $this->belongsTo(CourseOffering::class);
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function members(): HasMany
    {
        return $this->hasMany(GroupMember::class, 'group_id');
    }

    public function posts(): HasMany
    {
        return $this->hasMany(Post::class, 'group_id');
    }

    public function messages(): HasMany
    {
        return $this->hasMany(Message::class, 'group_id');
    }
}
