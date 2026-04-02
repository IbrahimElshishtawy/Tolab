<?php

namespace App\Modules\StaffPortal\Models;

use Illuminate\Database\Eloquent\Model;

class Permission extends Model
{
    protected $table = 'portal_permissions';

    protected $fillable = ['name', 'group_name', 'label'];
}
