<?php

return [
    'microsoft' => [
        'client_id' => env('MICROSOFT_CLIENT_ID'),
        'client_secret' => env('MICROSOFT_CLIENT_SECRET'),
        'redirect' => env('MICROSOFT_REDIRECT_URI'),
        'tenant' => env('MICROSOFT_TENANT_ID', 'organizations'),
        'include_avatar' => false,
    ],

    'frontend' => [
        'url' => env('FRONTEND_URL'),
    ],
];
