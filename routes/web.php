<?php

use App\Jobs\HelloJob;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/hello-job', function () {
    HelloJob::dispatch();
    return 'Finished';
});
