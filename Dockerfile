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

# Set Apache DocumentRoot to TestLink
RUN sed -i 's#DocumentRoot /var/www/html#DocumentRoot /var/www/html/testlink#g' /etc/apache2/sites-available/000-default.conf

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Railway will route to this port; we bind Apache to $PORT in entrypoint
EXPOSE 8080

WORKDIR /var/www/html/testlink
CMD ["/entrypoint.sh"]