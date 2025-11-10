#!/bin/sh
set -e

APP_DIR="/var/www/html/testlink"
CONFIG_FILE="${APP_DIR}/config_db.inc.php"

: "${TESTLINK_DATABASE_HOST:?Set TESTLINK_DATABASE_HOST}"
: "${TESTLINK_DATABASE_NAME:?Set TESTLINK_DATABASE_NAME}"
: "${TESTLINK_DATABASE_USER:?Set TESTLINK_DATABASE_USER}"
: "${TESTLINK_DATABASE_PASSWORD:?Set TESTLINK_DATABASE_PASSWORD}"

DB_TYPE="${TESTLINK_DATABASE_TYPE:-mysqli}"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Generating $CONFIG_FILE..."
  cat > "$CONFIG_FILE" <<EOF
<?php
define('DB_TYPE', '${DB_TYPE}');
define('DB_USER', '${TESTLINK_DATABASE_USER}');
define('DB_PASS', '${TESTLINK_DATABASE_PASSWORD}');
define('DB_HOST', '${TESTLINK_DATABASE_HOST}');
define('DB_NAME', '${TESTLINK_DATABASE_NAME}');
define('DB_TABLE_PREFIX', 'tl_');
?>
EOF
  chown www-data:www-data "$CONFIG_FILE"
fi

PORT="${PORT:-8080}"
echo "Using PORT=${PORT}"

# Bind Apache to Railway's dynamic port
sed -i "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf
sed -i "s/<VirtualHost \*:80>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf

echo "Starting Apache..."
exec apache2-foreground