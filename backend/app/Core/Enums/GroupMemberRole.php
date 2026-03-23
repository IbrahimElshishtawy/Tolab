<?php

namespace App\Core\Enums;

enum GroupMemberRole: string
{
    case OWNER = 'OWNER';
    case MOD = 'MOD';
    case MEMBER = 'MEMBER';
}
