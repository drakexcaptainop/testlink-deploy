FROM php:7.4-apache

ENV DEBIAN_FRONTEND=noninteractive
ENV TESTLINK_VERSION=1.9.20

# Install deps + PHP extensions for MySQL
RUN apt-get update \
 && apt-get install -y wget unzip ca-certificates libonig-dev \
 && docker-php-ext-install mbstring mysqli pdo pdo_mysql \
 && rm -rf /var/lib/apt/lists/*

# Download and install TestLink
RUN mkdir -p /var/www/html/testlink && \
    wget -O /tmp/testlink.tar.gz \
      "https://sourceforge.net/projects/testlink/files/TestLink%201.9/TestLink%201.9.20/testlink-${TESTLINK_VERSION}.tar.gz/download" && \
    tar -xzf /tmp/testlink.tar.gz -C /var/www/html/testlink --strip-components=1 && \
    rm /tmp/testlink.tar.gz && \
    chown -R www-data:www-data /var/www/html/testlink

# Apache vhost: point to TestLink and allow access
RUN cat << 'EOF' > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
    DocumentRoot /var/www/html/testlink

    <Directory /var/www/html/testlink>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Create log and upload dirs TestLink expects
RUN mkdir -p /var/testlink/logs /var/testlink/upload_area && \
    chown -R www-data:www-data /var/testlink && \
    chmod -R 755 /var/testlink

# Hard-code DB config using Railway MySQL credentials
# ⬇️ REPLACE these placeholders with your actual Railway MYSQL* values
RUN cat << 'EOF' > /var/www/html/testlink/config_db.inc.php
<?php
define('DB_TYPE', 'mysqli');
define('DB_USER', 'railway');             
define('DB_PASS', 'tXqYITFAqPbKvXHELnLhqmJMxFVTXVdF');    
define('DB_HOST', 'mysql.railway.internal');
define('DB_NAME', 'railway');             
define('DB_TABLE_PREFIX', 'tl_');
?>
EOF

# Entrypoint to adjust port for Railway and start Apache
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 
EXPOSE 8080
WORKDIR /var/www/html/testlink
CMD ["/entrypoint.sh"]