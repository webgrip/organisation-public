#!/bin/sh
set -e

echo "Starting Firefly III cron service..."

# Ensure log directory exists
mkdir -p /var/log/cron

# Initialize Laravel application
echo "Setting up Laravel application..."
cd /var/www/html

# Wait for database to be ready
echo "Waiting for database connection..."
until php artisan migrate:status > /dev/null 2>&1; do
    echo "Waiting for database..."
    sleep 5
done

# Ensure application key is set
if [ -z "$APP_KEY" ]; then
    echo "Warning: APP_KEY not set. Generating one..."
    php artisan key:generate --no-interaction
fi

# Clear and cache configuration
php artisan config:clear
php artisan config:cache
php artisan route:cache

echo "Starting cron daemon..."
# Ensure oauth keys in storage have correct permissions if writable
for key in /var/www/html/storage/oauth-public.key /var/www/html/storage/oauth-private.key; do
    if [ -e "$key" ]; then
        echo "Fixing permissions on $key"
        if chown www-data:www-data "$key" 2>/dev/null; then
            chmod 600 "$key" 2>/dev/null || true
        else
            echo "Warning: unable to chown $key (maybe mounted read-only). Continuing..."
        fi
    fi
done

# Start cron daemon in foreground. Debian uses 'cron', some images use 'crond'.
if command -v cron >/dev/null 2>&1; then
    echo "Using 'cron' binary"
    exec cron -f
elif command -v crond >/dev/null 2>&1; then
    echo "Using 'crond' binary"
    exec crond -f -l 8
else
    echo "Error: no cron binary found in the image (cron/crond). Exiting." >&2
    exit 1
fi
