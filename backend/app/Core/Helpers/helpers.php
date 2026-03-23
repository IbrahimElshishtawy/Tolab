<?php

use Illuminate\Http\JsonResponse;

if (! function_exists('api_success')) {
    function api_success(string $message, mixed $data = null, int $status = 200): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $data,
        ], $status);
    }
}

if (! function_exists('api_error')) {
    function api_error(string $message, mixed $errors = null, int $status = 422): JsonResponse
    {
        return response()->json([
            'success' => false,
            'message' => $message,
            'errors' => $errors ?? new stdClass(),
        ], $status);
    }
}
