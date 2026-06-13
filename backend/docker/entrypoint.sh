#!/bin/sh
set -e

# Wait for database if host and port are configured
if [ -n "$DB_HOST" ] && [ -n "$DB_PORT" ]; then
    echo "Checking connection to database at $DB_HOST:$DB_PORT..."
    # A simple timeout loop checking database availability
    timeout=30
    while ! nc -z "$DB_HOST" "$DB_PORT" >/dev/null 2>&1; do
        timeout=$((timeout - 1))
        if [ "$timeout" -le 0 ]; then
            echo "Warning: Database did not become available in time. Proceeding anyway..."
            break
        fi
        echo "Waiting for database... ($timeout seconds left)"
        sleep 1
    done
fi

# Run migrations if configured to run automatically
if [ "$RUN_MIGRATIONS" = "true" ]; then
    echo "Running database migrations..."
    php artisan migrate --force
fi

# Cache config, routes, and views for production performance
echo "Caching Laravel assets..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Set container role (defaults to 'app')
ROLE=${CONTAINER_ROLE:-app}

if [ "$ROLE" = "app" ]; then
    echo "Starting container in web-app role..."
    
    # Start PHP-FPM in daemon mode
    echo "Starting PHP-FPM..."
    php-fpm -D
    
    # Start Nginx in the foreground
    echo "Starting Nginx..."
    exec nginx -g "daemon off;"
    
elif [ "$ROLE" = "worker" ]; then
    echo "Starting container in queue-worker role..."
    
    # Start Supervisord in foreground to monitor Horizon/Workers
    exec supervisord -n -c /etc/supervisor/conf.d/supervisor.conf
    
elif [ "$ROLE" = "scheduler" ]; then
    echo "Starting container in cron-scheduler role..."
    
    # Run the Laravel schedule loop every minute
    echo "Running Laravel scheduler loop..."
    while true; do
        php artisan schedule:run --no-interaction &
        sleep 60
    done
    
else
    echo "Unknown role '$ROLE'. Executing custom command..."
    exec "$@"
fi
