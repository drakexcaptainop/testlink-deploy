#!/bin/sh
set -e

PORT="${PORT:-8080}"
echo "Using PORT=${PORT}"

# Ensure only one valid Listen line
# Delete any existing Listen directives, then add the correct one
sed -i '/^Listen /d' /etc/apache2/ports.conf
echo "Listen ${PORT}" >> /etc/apache2/ports.conf

# Also fix the VirtualHost port
sed -i "s/<VirtualHost .*>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf

echo "Checking Apache config syntax..."
apache2ctl configtest

echo "Starting Apache..."
exec apache2ctl -D FOREGROUND