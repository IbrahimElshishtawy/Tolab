<?php

use Illuminate\Http\JsonResponse;

if (! function_exists('api_success')) {
    function api_success(string $message, mixed $data = null, int $status = 200, ?array $meta = null): JsonResponse
    {
        $payload = [
            'success' => true,
            'message' => __($message),
            'data' => $data,
        ];

        if ($meta !== null) {
            $payload['meta'] = $meta;
        }

        return new JsonResponse($payload, $status);
    }
}

if (! function_exists('api_error')) {
    function api_error(string $message, mixed $errors = null, int $status = 422): JsonResponse
    {
        return new JsonResponse([
            'success' => false,
            'message' => __($message),
            'errors' => $errors ?? new \stdClass(),
        ], $status);
    }
}
