FROM php:8.4-fpm-alpine

# Set build-time variables
ARG WORKDIR=/var/www/html
ENV COMPOSER_ALLOW_SUPERUSER=1

# Install system dependencies
RUN apk add --no-cache \
    bash \
    curl \
    git \
    supervisor \
    nginx \
    mysql-client \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    zip \
    unzip \
    oniguruma-dev \
    icu-dev

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        bcmath \
        gd \
        zip \
        pcntl \
        posix \
        intl \
        opcache

# Install Redis extension via PECL
RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apk del .build-deps

# Copy Composer from the official image
COPY --from=composer:2.8 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR ${WORKDIR}

# Copy dependency definition files
COPY composer.json composer.lock ./

# Install dependencies (without running autoloader script or dev packages)
RUN composer install --no-dev --no-scripts --no-interaction --prefer-dist

# Copy the rest of the application files
COPY . .

# Generate optimized autoload files
RUN composer dump-autoload --no-dev --optimize

# Setup storage directory permissions
RUN mkdir -p storage/framework/{sessions,views,cache} bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Copy deployment configuration files
COPY docker/nginx.conf /etc/nginx/http.d/default.conf
COPY docker/supervisor.conf /etc/supervisor/conf.d/supervisor.conf
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh

# Make entrypoint executable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose ports for Nginx (80) and PHP-FPM (9000)
EXPOSE 80 9000

# Set entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
