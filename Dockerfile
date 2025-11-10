FROM php:7.4-apache

ENV DEBIAN_FRONTEND=noninteractive
ENV TESTLINK_VERSION=1.9.20

# Fix old Debian repos for php:7.4 image (EOL -> archive)
RUN sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list \
 && sed -i 's|security.debian.org|archive.debian.org|g' /etc/apt/sources.list \
 && apt-get update \
 && apt-get install -y wget unzip libpq-dev ca-certificates \
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

# Our entrypoint: write DB config & start Apache on $PORT
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Render will route to this exposed port; we remap 80 -> $PORT in entrypoint
EXPOSE 8080

WORKDIR /var/www/html/testlink
CMD ["/entrypoint.sh"]