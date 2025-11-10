#!/bin/sh
set -e

APP_DIR="/var/www/html/testlink"

PORT="${PORT:-8080}"
echo "Using PORT=${PORT}"

# Bind Apache to Railway's port
sed -i "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf
sed -i "s/<VirtualHost \*:80>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf
# 123
echo "Starting Apache..."
exec apache2-foreground