<?php

namespace App\Modules\Grades\Enums;

enum GradeType: string
{
    case MIDTERM = 'MIDTERM';
    case QUIZ = 'QUIZ';
    case TASK = 'TASK';
    case FINAL = 'FINAL';
    case ATTENDANCE = 'ATTENDANCE';
    case OTHER = 'OTHER';
}
