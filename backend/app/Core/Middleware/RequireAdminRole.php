<?php

namespace App\Core\Middleware;

use App\Core\Enums\UserRole;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class RequireAdminRole
{
    public function handle(Request $request, Closure $next)
    {
        $user = $request->user();

        if (! $user || $user->role !== UserRole::ADMIN) {
            return api_error('Admin access required.', [], Response::HTTP_FORBIDDEN);
        }

        return $next($request);
    }
}
