FROM php:7.4-apache

# Install required extensions
RUN apt-get update && apt-get install -y \
    libpq-dev libzip-dev unzip wget \
 && docker-php-ext-install mbstring zip pgsql pdo pdo_pgsql \
 && rm -rf /var/lib/apt/lists/*

# Download & install TestLink 1.9.20
ENV TESTLINK_VERSION=1.9.20
RUN wget -O /tmp/testlink.tar.gz \
      "https://sourceforge.net/projects/testlink/files/TestLink%201.9/TestLink%201.9.20/testlink-${TESTLINK_VERSION}.tar.gz/download" \
 && tar -xzf /tmp/testlink.tar.gz -C /var/www/html --strip-components=1 \
 && rm /tmp/testlink.tar.gz

# Permissions
RUN chown -R www-data:www-data /var/www/html

# Add entrypoint to auto-generate DB config from env vars
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]