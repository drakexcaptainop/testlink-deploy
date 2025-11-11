#!/bin/sh
set -e

PORT="${PORT:-8080}"
echo "Using PORT=${PORT}"

# Make Apache listen on the correct port
echo "Listen ${PORT}" > /etc/apache2/ports.conf

# Update VirtualHost port if needed
sed -i "s|<VirtualHost \*:80>|<VirtualHost *:${PORT}>|" /etc/apache2/sites-available/000-default.conf

# Basic config check
echo "Checking Apache syntax..."
apache2ctl configtest || true

echo "Starting Apache..."
exec apache2ctl -D FOREGROUND