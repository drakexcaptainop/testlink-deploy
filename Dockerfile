FROM php:7.4-apache

ENV DEBIAN_FRONTEND=noninteractive
ENV TESTLINK_VERSION=1.9.20

# ---- Install dependencies ----
RUN apt-get update \
 && apt-get install -y wget unzip ca-certificates libonig-dev \
 && docker-php-ext-install mbstring mysqli pdo pdo_mysql \
 && rm -rf /var/lib/apt/lists/*

# ---- Download TestLink ----
RUN mkdir -p /var/www/html/testlink && \
    wget -O /tmp/testlink.tar.gz \
      "https://sourceforge.net/projects/testlink/files/TestLink%201.9/TestLink%201.9.20/testlink-${TESTLINK_VERSION}.tar.gz/download" && \
    tar -xzf /tmp/testlink.tar.gz -C /var/www/html/testlink --strip-components=1 && \
    rm /tmp/testlink.tar.gz && \
    chown -R www-data:www-data /var/www/html/testlink

# ---- Apache VirtualHost ----
# ---- Apache VirtualHost (clean, no escapes) ----
RUN printf "%s\n" "\
ServerName localhost

<VirtualHost *:80>
    DocumentRoot /var/www/html/testlink

    <Directory /var/www/html/testlink>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog /var/log/apache2/error.log
    CustomLog /var/log/apache2/access.log combined
</VirtualHost>
" > /etc/apache2/sites-available/000-default.conf

# ---- Create TestLink-required folders ----
RUN mkdir -p /var/testlink/logs /var/testlink/upload_area && \
    chown -R www-data:www-data /var/testlink && \
    chmod -R 755 /var/testlink

# ---- Hard-code DB credentials (edit these 3 lines only) ----
RUN echo "<?php
define('DB_TYPE', 'mysqli');
define('DB_USER', 'railway');             // <<< your Railway MYSQLUSER
define('DB_PASS', 'tXqYITFAqPbKvXHELnLhqmJMxFVTXVdF');    // <<< your Railway MYSQLPASSWORD
define('DB_HOST', 'mysql.railway.internal');
define('DB_NAME', 'railway');             // <<< your Railway MYSQLDATABASE
define('DB_TABLE_PREFIX', 'tl_');
?>" > /var/www/html/testlink/config_db.inc.php

# ---- Copy startup script ----
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
WORKDIR /var/www/html/testlink
CMD ["/entrypoint.sh"]