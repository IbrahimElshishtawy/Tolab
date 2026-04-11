<?php

namespace App\Core\Middleware;

use App\Core\Enums\UserRole;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class RequireStudentRole
{
    public function handle(Request $request, Closure $next)
    {
        $user = $request->user();

        if (! $user || $user->role !== UserRole::STUDENT) {
            return api_error('Student access required.', [], Response::HTTP_FORBIDDEN);
        }

        return $next($request);
    }
}
