#!/bin/sh
set -e

APP_DIR="/var/www/html/testlink"
CONFIG_FILE="${APP_DIR}/config_db.inc.php"

: "${TL_DB_HOST:?Set TL_DB_HOST}"
: "${TL_DB_NAME:?Set TL_DB_NAME}"
: "${TL_DB_USER:?Set TL_DB_USER}"
: "${TL_DB_PASSWORD:?Set TL_DB_PASSWORD}"
: "${TL_DB_TYPE:=pgsql}"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Generating $CONFIG_FILE..."
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
fi

# Use Render's dynamic port (default 8080 if not set)
PORT="${PORT:-8080}"
echo "Using PORT=${PORT}"

# Update Apache to listen on $PORT
sed -i "s/Listen 80/Listen ${PORT}/" /etc/apache2/ports.conf
sed -i "s/:80>/:${PORT}>/" /etc/apache2/sites-available/000-default.conf

echo "Starting Apache..."
exec apache2-foreground