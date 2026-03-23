<?php

namespace App\Core\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureActiveUser
{
    public function handle(Request $request, Closure $next)
    {
        $user = $request->user();

        if ($user && ! $user->is_active) {
            return api_error('Your account is inactive.', [], Response::HTTP_FORBIDDEN);
        }

        return $next($request);
    }
}
