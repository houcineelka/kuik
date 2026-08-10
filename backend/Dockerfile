FROM php:8.3-cli

RUN apt-get update && apt-get install -y \
        git unzip libzip-dev libpng-dev libonig-dev libxml2-dev libsodium-dev \
    && docker-php-ext-install pdo_mysql mbstring bcmath sodium zip exif \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY . .

RUN composer install --no-dev --optimize-autoloader --no-interaction \
    && mkdir -p storage/framework/{cache,sessions,views} storage/logs bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

CMD ["sh", "-c", "if [ -n \"$FIREBASE_CREDENTIALS_JSON\" ]; then mkdir -p storage/app/firebase && printf '%s' \"$FIREBASE_CREDENTIALS_JSON\" > storage/app/firebase/service-account.json; fi; php artisan migrate --force; php artisan storage:link --force; php artisan serve --host=0.0.0.0 --port=${PORT:-8080}"]
