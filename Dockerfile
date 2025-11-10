FROM php:8.2-apache

ENV DEBIAN_FRONTEND=noninteractive
ENV TESTLINK_VERSION=1.9.20

# Install dependencies and PHP extensions for PostgreSQL + TestLink
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    libpq-dev \
    ca-certificates \
 && docker-php-ext-install pdo_pgsql pgsql mbstring \
 && rm -rf /var/lib/apt/lists/*

# Download and install TestLink
RUN mkdir -p /var/www/html/testlink && \
    wget -O /tmp/testlink.tar.gz \
      "https://sourceforge.net/projects/testlink/files/TestLink%201.9/TestLink%201.9.20/testlink-${TESTLINK_VERSION}.tar.gz/download" && \
    tar -xzf /tmp/testlink.tar.gz -C /var/www/html/testlink --strip-components=1 && \
    rm /tmp/testlink.tar.gz && \
    chown -R www-data:www-data /var/www/html/testlink

# Point Apache DocumentRoot to TestLink
RUN sed -i 's#DocumentRoot /var/www/html#DocumentRoot /var/www/html/testlink#g' /etc/apache2/sites-available/000-default.conf

# Our entrypoint wires DB config and starts Apache
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Render sets $PORT; we'll bind Apache to that in entrypoint.
EXPOSE 8080

WORKDIR /var/www/html/testlink

CMD ["/entrypoint.sh"]