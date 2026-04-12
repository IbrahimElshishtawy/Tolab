<?php

namespace App\Core\Middleware;

use App\Core\Enums\UserRole;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class RequireStaffRole
{
    public function handle(Request $request, Closure $next)
    {
        $user = $request->user();

        if (! $user || ! in_array($user->role, [UserRole::DOCTOR, UserRole::TA], true)) {
            return api_error('Doctor or assistant access required.', [], Response::HTTP_FORBIDDEN);
        }

        return $next($request);
    }
}
