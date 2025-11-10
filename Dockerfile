FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV TESTLINK_VERSION=1.9.20

# Install Apache, PHP and required extensions
RUN apt-get update && apt-get install -y \
    apache2 \
    libapache2-mod-php \
    php \
    php-cli \
    php-pgsql \
    php-mbstring \
    php-xml \
    php-gd \
    php-zip \
    php-curl \
    wget \
    unzip \
    ca-certificates \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Download and install TestLink
RUN mkdir -p /var/www/html/testlink && \
    wget -O /tmp/testlink.tar.gz \
      "https://sourceforge.net/projects/testlink/files/TestLink%201.9/TestLink%201.9.20/testlink-${TESTLINK_VERSION}.tar.gz/download" && \
    tar -xzf /tmp/testlink.tar.gz -C /var/www/html/testlink --strip-components=1 && \
    rm /tmp/testlink.tar.gz && \
    chown -R www-data:www-data /var/www/html/testlink

# Point Apache to TestLink
RUN sed -i 's|/var/www/html|/var/www/html/testlink|g' /etc/apache2/sites-available/000-default.conf

# Simple health check: ensure Apache uses PHP module
RUN a2enmod php* >/dev/null 2>&1 || true

# Entrypoint to generate config_db.inc.php from env vars and start Apache
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

CMD ["/entrypoint.sh"]