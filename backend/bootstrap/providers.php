<?php

use App\Providers\AppServiceProvider;
use App\Providers\AuthServiceProvider;
use Laravel\Socialite\SocialiteServiceProvider;

return [
    AppServiceProvider::class,
    AuthServiceProvider::class,
    SocialiteServiceProvider::class,
];
