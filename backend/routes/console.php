<?php

use Illuminate\Support\Facades\Artisan;

Artisan::command('app:about', function () {
    $this->comment('Tolab University backend is ready.');
});
