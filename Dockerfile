FROM php:7.4-apache

ENV DEBIAN_FRONTEND=noninteractive
ENV TESTLINK_VERSION=1.9.20

# Fix EOL Debian repos for php:7.4 image
RUN sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list \
 && sed -i 's|security.debian.org|archive.debian.org|g' /etc/apt/sources.list \
 && sed -i '/stretch-updates/d' /etc/apt/sources.list || true \
 && apt-get update \
 && apt-get install -y wget unzip ca-certificates \
 && docker-php-ext-install mysqli pdo pdo_mysql mbstring \
 && rm -rf /var/lib/apt/lists/*

# Download & install TestLink
RUN mkdir -p /var/www/html/testlink && \
    wget -O /tmp/testlink.tar.gz \
      "https://sourceforge.net/projects/testlink/files/TestLink%201.9/TestLink%201.9.20/testlink-${TESTLINK_VERSION}.tar.gz/download" && \
    tar -xzf /tmp/testlink.tar.gz -C /var/www/html/testlink --strip-components=1 && \
    rm /tmp/testlink.tar.gz && \
    chown -R www-data:www-data /var/www/html/testlink

# Point Apache to TestLink
RUN sed -i 's#DocumentRoot /var/www/html#DocumentRoot /var/www/html/testlink#g' /etc/apache2/sites-available/000-default.conf

# Entrypoint to write DB config and start Apache on Railway's $PORT
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
WORKDIR /var/www/html/testlink
CMD ["/entrypoint.sh"]