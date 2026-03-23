<?php

use App\Modules\Moderation\Controllers\ModerationController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth:sanctum', 'active', 'admin', 'throttle:api'])->prefix('admin')->group(function () {
    Route::delete('posts/{post}', [ModerationController::class, 'deletePost'])->middleware('throttle:sensitive');
    Route::delete('comments/{comment}', [ModerationController::class, 'deleteComment'])->middleware('throttle:sensitive');
    Route::delete('messages/{message}', [ModerationController::class, 'deleteMessage'])->middleware('throttle:sensitive');
});
