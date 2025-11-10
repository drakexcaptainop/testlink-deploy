#!/bin/sh
set -e

APP_DIR="/var/www/html/testlink"
CONFIG_FILE="${APP_DIR}/config_db.inc.php"

# Read env vars (don't hard-crash if missing; just log)
: "${TL_DB_HOST:=}"
: "${TL_DB_NAME:=}"
: "${TL_DB_USER:=}"
: "${TL_DB_PASSWORD:=}"
: "${TL_DB_TYPE:=pgsql}"

echo "Starting TestLink container..."
echo "TL_DB_HOST=${TL_DB_HOST}"
echo "TL_DB_NAME=${TL_DB_NAME}"
echo "TL_DB_USER=${TL_DB_USER}"
echo "TL_DB_TYPE=${TL_DB_TYPE}"

# If DB variables are present and config does not exist, create it
if [ -n "$TL_DB_HOST" ] && [ -n "$TL_DB_NAME" ] && [ -n "$TL_DB_USER" ] && [ -n "$TL_DB_PASSWORD" ]; then
  if [ ! -f "$CONFIG_FILE" ]; then
    echo "Generating ${CONFIG_FILE} ..."
    cat > "$CONFIG_FILE" <<EOF
<?php
define('DB_TYPE', '${TL_DB_TYPE}');
define('DB_USER', '${TL_DB_USER}');
define('DB_PASS', '${TL_DB_PASSWORD}');
define('DB_HOST', '${TL_DB_HOST}');
define('DB_NAME', '${TL_DB_NAME}');
define('DB_TABLE_PREFIX', 'tl_');
?>
EOF
    chown www-data:www-data "$CONFIG_FILE"
  else
    echo "Config file already exists, skipping generation."
  fi
else
  echo "WARNING: Missing DB env vars, TestLink may not connect to DB."
fi

# Configure Apache to listen on Render's $PORT (default 8080 if not set)
PORT="${PORT:-8080}"
echo "Using PORT=${PORT} for Apache"
sed -i "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf || true
sed -i "s/:80>/:${PORT}>/" /etc/apache2/sites-available/000-default.conf || true

# Start Apache in foreground so Render sees a running web server
echo "Starting Apache..."
exec apache2-foreground