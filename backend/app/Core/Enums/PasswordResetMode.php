<?php

namespace App\Core\Enums;

enum PasswordResetMode: string
{
    case DEFAULT = 'DEFAULT';
    case CUSTOM = 'CUSTOM';
}
