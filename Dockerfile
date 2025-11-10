FROM php:8.1-apache

# Make sure we have all needed tools & headers
RUN set -eux; \
    apt-get update; \
    apt-get install -y \
        libpq-dev \
        libzip-dev \
        unzip \
        wget; \
    docker-php-ext-configure zip; \
    docker-php-ext-install -j"$(nproc)" mbstring zip pdo_pgsql pgsql; \
    rm -rf /var/lib/apt/lists/*

# TestLink version
ENV TESTLINK_VERSION=1.9.20

# Download & install TestLink
RUN set -eux; \
    wget -O /tmp/testlink.tar.gz \
      "https://sourceforge.net/projects/testlink/files/TestLink%201.9/TestLink%201.9.20/testlink-${TESTLINK_VERSION}.tar.gz/download"; \
    tar -xzf /tmp/testlink.tar.gz -C /var/www/html --strip-components=1; \
    rm /tmp/testlink.tar.gz; \
    chown -R www-data:www-data /var/www/html

# Entrypoint to wire env vars into config_db.inc.php
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]