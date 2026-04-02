<?php

namespace App\Modules\StaffPortal\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Role extends Model
{
    protected $table = 'portal_roles';

    protected $fillable = ['name', 'label'];

    public function permissions(): BelongsToMany
    {
        return $this->belongsToMany(Permission::class, 'portal_permission_role');
    }
}
