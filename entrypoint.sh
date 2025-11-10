#!/bin/sh
set -e

: "${TL_DB_HOST:?Set TL_DB_HOST}"
: "${TL_DB_NAME:?Set TL_DB_NAME}"
: "${TL_DB_USER:?Set TL_DB_USER}"
: "${TL_DB_PASSWORD:?Set TL_DB_PASSWORD}"
: "${TL_DB_TYPE:=pgsql}"

CONFIG_FILE="/var/www/html/config_db.inc.php"

if [ ! -f "$CONFIG_FILE" ]; then
  cat > "$CONFIG_FILE" <<EOF
<?php
define('DB_TYPE', '${TL_DB_TYPE}');
define('DB_USER', '${TL_DB_USER}');
define('DB_PASS', '${TL_DB_PASSWORD}');
define('DB_HOST', '${TL_DB_HOST}');
define('DB_NAME', '${TL_DB_NAME}');
define('DB_TABLE_PREFIX', 'tl_');
EOF
  chown www-data:www-data "$CONFIG_FILE"
fi

exec "$@"