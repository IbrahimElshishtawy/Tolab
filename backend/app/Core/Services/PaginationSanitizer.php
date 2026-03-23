<?php

namespace App\Core\Services;

use Illuminate\Http\Request;

class PaginationSanitizer
{
    public function perPage(Request $request, int $default = 15, int $max = 100): int
    {
        $value = (int) $request->integer('per_page', $default);

        if ($value < 1) {
            return $default;
        }

        return min($value, $max);
    }

    public function cursorLimit(Request $request, int $default = 20, int $max = 100): int
    {
        $value = (int) $request->integer('limit', $default);

        if ($value < 1) {
            return $default;
        }

        return min($value, $max);
    }
}
