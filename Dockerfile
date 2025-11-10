FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TESTLINK_VERSION=1.9.20

# Install Apache + PHP + extensions
RUN apt-get update && apt-get install -y \
    apache2 \
    php \
    php-pgsql \
    php-mbstring \
    php-xml \
    php-gd \
    php-curl \
    wget \
    unzip \
    ca-certificates \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Download and install TestLink
RUN mkdir -p /var/www/html/testlink && \
    wget -O /tmp/testlink.tar.gz \
      "https://sourceforge.net/projects/testlink/files/TestLink%201.9/TestLink%201.9.20/testlink-${TESTLINK_VERSION}.tar.gz/download" && \
    tar -xzf /tmp/testlink.tar.gz -C /var/www/html/testlink --strip-components=1 && \
    rm /tmp/testlink.tar.gz && \
    chown -R www-data:www-data /var/www/html/testlink

# Point Apache to TestLink directory
RUN sed -i 's#DocumentRoot /var/www/html#DocumentRoot /var/www/html/testlink#g' /etc/apache2/sites-available/000-default.conf

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Render will inject $PORT (we'll use it below)
EXPOSE 8080

WORKDIR /var/www/html/testlink
CMD ["/entrypoint.sh"]