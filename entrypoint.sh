#!/bin/sh
set -e

APP_DIR="/var/www/html/testlink"
CONFIG_FILE="${APP_DIR}/config_db.inc.php"

# Get DB settings from env (Railway MySQL)
: "${TESTLINK_DATABASE_HOST:?Set TESTLINK_DATABASE_HOST}"
: "${TESTLINK_DATABASE_NAME:?Set TESTLINK_DATABASE_NAME}"
: "${TESTLINK_DATABASE_USER:?Set TESTLINK_DATABASE_USER}"
: "${TESTLINK_DATABASE_PASSWORD:?Set TESTLINK_DATABASE_PASSWORD}"

DB_TYPE="${TESTLINK_DATABASE_TYPE:-mysqli}"


chown www-data:www-data "$CONFIG_FILE"

PORT="${PORT:-8080}"
echo "Using PORT=${PORT}"

# Make Apache listen on Railway's port
sed -i "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf
sed -i "s/<VirtualHost \*:80>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf

echo "Starting Apache..."
exec apache2-foreground