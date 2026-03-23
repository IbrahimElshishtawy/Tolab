<?php

use App\Modules\Group\Controllers\GroupController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth:sanctum', 'active', 'throttle:api'])->group(function () {
    Route::get('student/courses/{courseOffering}/group', [GroupController::class, 'studentCourseGroup']);
    Route::get('groups/{group}', [GroupController::class, 'show']);
    Route::get('groups/{group}/posts', [GroupController::class, 'posts']);
    Route::post('groups/{group}/posts', [GroupController::class, 'storePost'])->middleware('throttle:sensitive');
    Route::delete('posts/{post}', [GroupController::class, 'deletePost'])->middleware('throttle:sensitive');
    Route::get('posts/{post}/comments', [GroupController::class, 'comments']);
    Route::post('posts/{post}/comments', [GroupController::class, 'storeComment'])->middleware('throttle:sensitive');
    Route::delete('comments/{comment}', [GroupController::class, 'deleteComment'])->middleware('throttle:sensitive');
    Route::get('groups/{group}/messages', [GroupController::class, 'messages']);
    Route::post('groups/{group}/messages', [GroupController::class, 'storeMessage'])->middleware('throttle:sensitive');
});
