<?php

namespace App\Core\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsurePermission
{
    public function handle(Request $request, Closure $next, string $permission): Response
    {
        $user = $request->user();

        abort_unless($user && $user->hasPermission($permission), Response::HTTP_FORBIDDEN, 'You do not have permission to access this resource.');

        return $next($request);
    }
}
