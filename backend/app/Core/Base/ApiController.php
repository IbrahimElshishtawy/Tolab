<?php

namespace App\Core\Base;

use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Foundation\Validation\ValidatesRequests;
use Illuminate\Http\JsonResponse;
use Illuminate\Routing\Controller;

abstract class ApiController extends Controller
{
    use AuthorizesRequests;
    use ValidatesRequests;

    protected function success(string $message, mixed $data = null, int $status = 200): JsonResponse
    {
        return api_success($message, $data, $status);
    }

    protected function error(string $message, mixed $errors = null, int $status = 422): JsonResponse
    {
        return api_error($message, $errors, $status);
    }
}
