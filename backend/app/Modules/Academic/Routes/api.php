<?php

use App\Modules\Academic\Controllers\CourseOfferingController;
use App\Modules\Academic\Controllers\DepartmentController;
use App\Modules\Academic\Controllers\SectionController;
use App\Modules\Academic\Controllers\StudentCourseController;
use App\Modules\Academic\Controllers\SubjectController;
use Illuminate\Support\Facades\Route;

Route::get('departments', [DepartmentController::class, 'index']);
Route::get('sections', [SectionController::class, 'index']);
Route::get('subjects', [SubjectController::class, 'index']);

Route::middleware(['auth:sanctum', 'active', 'throttle:api'])->group(function () {
    Route::get('student/courses', [StudentCourseController::class, 'index']);
    Route::get('student/courses/{courseOffering}', [StudentCourseController::class, 'show']);
    Route::get('student/courses/{courseOffering}/content', [StudentCourseController::class, 'content']);
});

Route::middleware(['auth:sanctum', 'active', 'admin', 'throttle:api'])->prefix('admin')->group(function () {
    Route::post('departments', [DepartmentController::class, 'store'])->middleware('throttle:sensitive');
    Route::post('sections', [SectionController::class, 'store'])->middleware('throttle:sensitive');
    Route::post('subjects', [SubjectController::class, 'store'])->middleware('throttle:sensitive');
    Route::put('subjects/{subject}', [SubjectController::class, 'update'])->middleware('throttle:sensitive');
    Route::post('course-offerings', [CourseOfferingController::class, 'store'])->middleware('throttle:sensitive');
    Route::put('course-offerings/{courseOffering}', [CourseOfferingController::class, 'update'])->middleware('throttle:sensitive');
    Route::get('course-offerings', [CourseOfferingController::class, 'index']);
});
