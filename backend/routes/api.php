<?php

foreach (collect(glob(app_path('Modules/*/Routes/api.php')) ?: [])->sort()->values() as $routeFile) {
    require $routeFile;
}
