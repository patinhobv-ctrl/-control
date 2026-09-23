# StockControl - Laravel + PHP 8.2 para Render
FROM php:8.2-cli

# Instalar dependencias del sistema y extensiones PHP
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libpq-dev \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-install \
        pdo \
        pdo_pgsql \
        pdo_mysql \
        pdo_sqlite \
        zip \
        mbstring \
        bcmath \
        pcntl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Copiar composer y instalar dependencias primero (cache)
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader --no-scripts

# Copiar resto del proyecto
COPY . .

# Permisos storage y cache
RUN mkdir -p storage/framework/{sessions,views,cache} storage/logs bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Instalar dependencias restantes y optimizar
RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist \
    && php artisan package:discover --ansi || true

# Puerto Render (inyecta $PORT)
EXPOSE 10000

# Script de inicio: migra, cachea y sirve
RUN printf '#!/bin/sh\n\
set -e\n\
echo "== StockControl iniciando =="\n\
# Generar APP_KEY si no es base64\n\
if ! echo "$APP_KEY" | grep -q "base64"; then\n\
  echo "Generando APP_KEY..."\n\
  export APP_KEY=$(php artisan key:generate --show)\n\
  echo "APP_KEY generada"\n\
fi\n\
php artisan config:clear\n\
echo "Migrando BD..."\n\
php artisan migrate --force --no-interaction || true\n\
# Seed si BD vacía (opcional)\n\
if [ "$SEED_DB" = "true" ]; then\n\
  echo "Seeding..."\n\
  php artisan db:seed --force --no-interaction || true\n\
fi\n\
php artisan config:cache\n\
php artisan route:cache\n\
php artisan view:cache\n\
echo "== Sirviendo en puerto \$PORT =="\n\
php artisan serve --host=0.0.0.0 --port=\${PORT:-10000}\n\
' > /app/start.sh && chmod +x /app/start.sh

CMD ["/app/start.sh"]