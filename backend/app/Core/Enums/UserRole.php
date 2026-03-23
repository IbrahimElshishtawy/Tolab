<?php

namespace App\Core\Enums;

enum UserRole: string
{
    case ADMIN = 'ADMIN';
    case STUDENT = 'STUDENT';
    case DOCTOR = 'DOCTOR';
    case TA = 'TA';

    public function isStaff(): bool
    {
        return in_array($this, [self::DOCTOR, self::TA], true);
    }
}
