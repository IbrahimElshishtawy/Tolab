<?php

use App\Modules\StaffPortal\Controllers\AdminController;
use App\Modules\StaffPortal\Controllers\AuthController;
use App\Modules\StaffPortal\Controllers\DashboardController;
use App\Modules\StaffPortal\Controllers\LectureController;
use App\Modules\StaffPortal\Controllers\NotificationController;
use App\Modules\StaffPortal\Controllers\ProfileController;
use App\Modules\StaffPortal\Controllers\QuizController;
use App\Modules\StaffPortal\Controllers\ScheduleController;
use App\Modules\StaffPortal\Controllers\SectionContentController;
use App\Modules\StaffPortal\Controllers\StaffController;
use App\Modules\StaffPortal\Controllers\SubjectController;
use App\Modules\StaffPortal\Controllers\TaskController;
use App\Modules\StaffPortal\Controllers\UploadController;
use Illuminate\Support\Facades\Route;

Route::prefix('staff-portal')->group(function () {
    Route::post('auth/login', [AuthController::class, 'login'])->middleware('throttle:login');
    Route::post('auth/refresh', [AuthController::class, 'refresh'])->middleware('throttle:sensitive');
    Route::post('auth/forgot-password', [AuthController::class, 'forgotPassword'])->middleware('throttle:sensitive');

    Route::middleware(['auth:sanctum', 'active', 'throttle:api'])->group(function () {
        Route::post('auth/logout', [AuthController::class, 'logout'])->middleware('throttle:sensitive');

        Route::get('dashboard', [DashboardController::class, 'index'])->middleware('staff_role');
        Route::get('profile', [ProfileController::class, 'show']);
        Route::put('profile/settings', [ProfileController::class, 'updateSettings'])->middleware('throttle:sensitive');

        Route::get('subjects', [SubjectController::class, 'index'])->middleware('permission:subjects.view');
        Route::get('subjects/{subject}', [SubjectController::class, 'show'])->middleware('permission:subjects.view');
        Route::get('lectures', [LectureController::class, 'index'])->middleware('permission:lectures.view');
        Route::post('lectures', [LectureController::class, 'store'])->middleware('permission:lectures.create');
        Route::delete('lectures/{lecture}', [LectureController::class, 'destroy'])->middleware('permission:lectures.delete');
        Route::get('section-content', [SectionContentController::class, 'index'])->middleware('permission:section_content.view');
        Route::post('section-content', [SectionContentController::class, 'store'])->middleware('permission:section_content.create');
        Route::get('quizzes', [QuizController::class, 'index'])->middleware('permission:quizzes.view');
        Route::post('quizzes', [QuizController::class, 'store'])->middleware('permission:quizzes.create');
        Route::get('tasks', [TaskController::class, 'index'])->middleware('permission:tasks.view');
        Route::post('tasks', [TaskController::class, 'store'])->middleware('permission:tasks.create');
        Route::get('schedule', [ScheduleController::class, 'index'])->middleware('permission:schedule.view');
        Route::get('notifications', [NotificationController::class, 'index'])->middleware('permission:notifications.view');
        Route::patch('notifications/{notification}/read', [NotificationController::class, 'markRead'])->middleware('permission:notifications.view');
        Route::get('uploads', [UploadController::class, 'index'])->middleware('permission:uploads.view');
        Route::post('uploads', [UploadController::class, 'store'])->middleware('permission:uploads.create');

        Route::prefix('admin')->middleware('permission:staff.view')->group(function () {
            Route::get('overview', [AdminController::class, 'overview']);
            Route::get('permissions', [AdminController::class, 'permissions']);
            Route::get('departments', [AdminController::class, 'departments']);
            Route::get('staff', [StaffController::class, 'index']);
            Route::patch('staff/{user}/activation', [StaffController::class, 'toggleActivation'])->middleware('permission:staff.update');
        });
    });
});

Route::prefix('staff')->middleware(['auth:sanctum', 'active', 'throttle:api', 'staff_role'])->group(function () {
    Route::get('dashboard', [DashboardController::class, 'index']);
});
