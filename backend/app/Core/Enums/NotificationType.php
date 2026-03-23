<?php

namespace App\Core\Enums;

enum NotificationType: string
{
    case SYSTEM = 'SYSTEM';
    case BROADCAST = 'BROADCAST';
    case GRADE = 'GRADE';
    case CONTENT = 'CONTENT';
    case MODERATION = 'MODERATION';
}
