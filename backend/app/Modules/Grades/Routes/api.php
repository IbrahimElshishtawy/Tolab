<?php

use App\Modules\Grades\Controllers\GradeController;
use App\Modules\Grades\Controllers\StudentGradeController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth:sanctum', 'active', 'student', 'throttle:api'])->group(function () {
    Route::get('student/courses/{courseOffering}/grades', [StudentGradeController::class, 'index']);
});

Route::middleware(['auth:sanctum', 'active', 'admin', 'throttle:api'])->prefix('admin')->group(function () {
    Route::get('courses/{courseOffering}/grades', [GradeController::class, 'index']);
    Route::post('courses/{courseOffering}/grades', [GradeController::class, 'store'])->middleware('throttle:sensitive');
    Route::put('grades/{grade}', [GradeController::class, 'update'])->middleware('throttle:sensitive');
    Route::delete('grades/{grade}', [GradeController::class, 'destroy'])->middleware('throttle:sensitive');
});

Route::middleware(['auth:sanctum', 'active', 'throttle:api'])->prefix('v1')->group(function () {
    Route::get('subjects/{subject}/results', [\App\Modules\Grades\Controllers\GradingApiController::class, 'index']);
    Route::post('subjects/{subject}/grades/draft', [\App\Modules\Grades\Controllers\GradingApiController::class, 'draft'])->middleware('throttle:sensitive');
    Route::post('subjects/{subject}/grades/publish', [\App\Modules\Grades\Controllers\GradingApiController::class, 'publish'])->middleware('throttle:sensitive');
    Route::post('subjects/{subject}/grades/upload-sheet', [\App\Modules\Grades\Controllers\GradingApiController::class, 'uploadSheet'])->middleware('throttle:sensitive');

    Route::get('student/dashboard', [\App\Modules\Grades\Controllers\StudentPortalController::class, 'dashboard'])->middleware('student');
});

