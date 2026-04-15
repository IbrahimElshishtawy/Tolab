<?php

namespace App\Core\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\Response;

class SetRequestLocale
{
    public function handle(Request $request, Closure $next): Response
    {
        $locale = $this->resolveLocale($request);

        app()->setLocale($locale);

        return $next($request);
    }

    protected function resolveLocale(Request $request): string
    {
        $accepted = Str::of((string) $request->header('Accept-Language'))
            ->before(',')
            ->before(';')
            ->lower()
            ->trim()
            ->toString();

        if (in_array($accepted, ['en', 'ar'], true)) {
            return $accepted;
        }

        $userLocale = Str::of((string) optional($request->user())->language)
            ->lower()
            ->trim()
            ->toString();

        if (in_array($userLocale, ['en', 'ar'], true)) {
            return $userLocale;
        }

        return config('app.locale', 'en');
    }
}
