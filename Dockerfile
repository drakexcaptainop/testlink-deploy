FROM php:7.4-apache

ENV DEBIAN_FRONTEND=noninteractive
ENV TESTLINK_VERSION=1.9.20

# Install dependencies + PHP extensions
RUN apt-get update \
 && apt-get install -y wget unzip ca-certificates libonig-dev \
 && docker-php-ext-install mbstring mysqli pdo pdo_mysql \
 && rm -rf /var/lib/apt/lists/*

# Download and install TestLink into /var/www/html/testlink
RUN mkdir -p /var/www/html/testlink && \
    wget -O /tmp/testlink.tar.gz \
      "https://sourceforge.net/projects/testlink/files/TestLink%201.9/TestLink%201.9.20/testlink-${TESTLINK_VERSION}.tar.gz/download" && \
    tar -xzf /tmp/testlink.tar.gz -C /var/www/html/testlink --strip-components=1 && \
    rm /tmp/testlink.tar.gz && \
    chown -R www-data:www-data /var/www/html/testlink

# Clean Apache vhost: ServerName + DocumentRoot + permissions
RUN printf '%s\n' \
'ServerName localhost' \
'' \
'<VirtualHost *:80>' \
'    DocumentRoot /var/www/html/testlink' \
'' \
'    <Directory /var/www/html/testlink>' \
'        Options Indexes FollowSymLinks' \
'        AllowOverride All' \
'        Require all granted' \
'    </Directory>' \
'' \
'    ErrorLog /var/log/apache2/error.log' \
'    CustomLog /var/log/apache2/access.log combined' \
'</VirtualHost>' \
> /etc/apache2/sites-available/000-default.conf

# Folders TestLink expects (logs, uploads)
RUN mkdir -p /var/testlink/logs /var/testlink/upload_area && \
    chown -R www-data:www-data /var/testlink && \
    chmod -R 755 /var/testlink

# Hard-code DB config using Railway MySQL credentials
# 🚨 EDIT THESE THREE LINES to match your Railway MySQL service:
#   - DB_USER  = MYSQLUSER
#   - DB_PASS  = MYSQLPASSWORD
#   - DB_NAME  = MYSQLDATABASE
RUN printf '%s\n' \
'<?php' \
"define('DB_TYPE', 'mysqli');" \
"define('DB_USER', 'railway');" \        # <<< change to your MYSQLUSER
"define('DB_PASS', 'aBcDeFgHiJK12345');" \  # <<< change to your MYSQLPASSWORD
"define('DB_HOST', 'mysql.railway.internal');" \
"define('DB_NAME', 'railway');" \        # <<< change to your MYSQLDATABASE
"define('DB_TABLE_PREFIX', 'tl_');" \
'?>' \
> /var/www/html/testlink/config_db.inc.php

# Copy startup script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
WORKDIR /var/www/html/testlink

CMD ["/entrypoint.sh"]