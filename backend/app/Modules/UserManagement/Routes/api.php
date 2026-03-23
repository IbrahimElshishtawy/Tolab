<?php

use App\Modules\UserManagement\Controllers\AdminUserController;
use App\Modules\UserManagement\Controllers\ImportController;
use App\Modules\UserManagement\Controllers\MeController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth:sanctum', 'active', 'throttle:api'])->group(function () {
    Route::get('me', [MeController::class, 'me']);
    Route::get('me/profile', [MeController::class, 'profile']);
    Route::put('me/profile', [MeController::class, 'updateProfile'])->middleware('throttle:sensitive');

    Route::prefix('admin')->middleware('admin')->group(function () {
        Route::get('users', [AdminUserController::class, 'index']);
        Route::post('users', [AdminUserController::class, 'store'])->middleware('throttle:sensitive');
        Route::put('users/{user}', [AdminUserController::class, 'update'])->middleware('throttle:sensitive');
        Route::patch('users/{user}/activate', [AdminUserController::class, 'activate'])->middleware('throttle:sensitive');
        Route::post('users/{user}/reset-password', [AdminUserController::class, 'resetPassword'])->middleware('throttle:sensitive');

        Route::post('import/students', [ImportController::class, 'students'])->middleware('throttle:sensitive');
        Route::post('import/staff', [ImportController::class, 'staff'])->middleware('throttle:sensitive');
    });
});
