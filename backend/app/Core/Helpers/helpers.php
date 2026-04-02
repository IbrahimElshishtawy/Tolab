<?php

use Illuminate\Http\JsonResponse;
use stdClass;

if (! function_exists('api_success')) {
    function api_success(string $message, mixed $data = null, int $status = 200): JsonResponse
    {
        return new JsonResponse([
            'success' => true,
            'message' => $message,
            'data' => $data,
        ], $status);
    }
}

if (! function_exists('api_error')) {
    function api_error(string $message, mixed $errors = null, int $status = 422): JsonResponse
    {
        return new JsonResponse([
            'success' => false,
            'message' => $message,
            'errors' => $errors ?? new stdClass(),
        ], $status);
    }
}
