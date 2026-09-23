# StockControl - Laravel + PHP 8.2 para Render
FROM php:8.2-cli
RUN apt-get update && apt-get install -y git unzip libzip-dev libpq-dev libonig-dev libxml2-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libicu-dev && docker-php-ext-configure gd --with-freetype --with-jpeg && docker-php-ext-install -j$(nproc) pdo pdo_pgsql pdo_mysql pdo_sqlite zip mbstring bcmath pcntl gd intl && apt-get clean && rm -rf /var/lib/apt/lists/*
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader --no-scripts
COPY . .
RUN mkdir -p storage/framework/{sessions,views,cache} storage/logs bootstrap/cache && chmod -R 775 storage bootstrap/cache
RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist && php artisan package:discover --ansi || true
EXPOSE 10000
RUN printf '#!/bin/sh\nset -e\necho "== StockControl iniciando =="\nif ! echo "$APP_KEY" | grep -q "base64"; then export APP_KEY=$(php artisan key:generate --show); fi\nphp artisan config:clear\nphp artisan migrate --force --no-interaction || true\nif [ "$SEED_DB" = "true" ]; then php artisan db:seed --force --no-interaction || true; fi\nphp artisan config:cache\nphp artisan route:cache\nphp artisan view:cache\necho "== Sirviendo en puerto $PORT =="\nphp artisan serve --host=0.0.0.0 --port=${PORT:-10000}\n' > /app/start.sh && chmod +x /app/start.sh
CMD ["/app/start.sh"]
