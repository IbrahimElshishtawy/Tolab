<?php

namespace App\Modules\Content\Domain\Enums;

enum AssessmentType: string
{
    case TASK = 'TASK';
    case QUIZ = 'QUIZ';
    case SHEET = 'SHEET';
}
