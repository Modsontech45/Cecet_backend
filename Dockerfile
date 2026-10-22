FROM php:8.3-cli-alpine

# System deps
RUN apk add --no-cache \
    postgresql-client \
    libpq-dev \
    zip unzip git curl icu-dev

# PHP extensions
RUN apk add --no-cache libzip-dev \
 && docker-php-ext-install pdo pdo_pgsql intl zip

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY . .

RUN composer install --no-dev --optimize-autoloader --no-interaction

RUN chown -R www-data:www-data storage bootstrap/cache

EXPOSE 8000

CMD php artisan config:cache && \
    php artisan route:cache && \
    php artisan migrate --force && \
    php artisan serve --host=0.0.0.0 --port=8000
