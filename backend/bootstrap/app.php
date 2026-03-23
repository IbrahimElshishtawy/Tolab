<?php

use App\Core\Exceptions\ApiException;
use App\Core\Middleware\EnsureActiveUser;
use App\Core\Middleware\ForceJsonResponse;
use App\Core\Middleware\RequireAdminRole;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpFoundation\Response;
use Throwable;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->append(ForceJsonResponse::class);
        $middleware->alias([
            'active' => EnsureActiveUser::class,
            'admin' => RequireAdminRole::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->render(function (ValidationException $exception, Request $request) {
            return api_error('Validation failed.', $exception->errors(), Response::HTTP_UNPROCESSABLE_ENTITY);
        });

        $exceptions->render(function (AuthenticationException $exception, Request $request) {
            return api_error('Unauthenticated.', [], Response::HTTP_UNAUTHORIZED);
        });

        $exceptions->render(function (AuthorizationException $exception, Request $request) {
            return api_error($exception->getMessage() ?: 'Forbidden.', [], Response::HTTP_FORBIDDEN);
        });

        $exceptions->render(function (ModelNotFoundException $exception, Request $request) {
            return api_error('Resource not found.', [], Response::HTTP_NOT_FOUND);
        });

        $exceptions->render(function (ApiException $exception, Request $request) {
            return api_error($exception->getMessage(), $exception->getErrors(), $exception->getStatus());
        });

        $exceptions->render(function (Throwable $exception, Request $request) {
            report($exception);

            return api_error('Server error.', [], Response::HTTP_INTERNAL_SERVER_ERROR);
        });
    })
    ->create();
