#
# Vendor Dependencies
#
FROM serversideup/php:8.3-cli AS vendor

# This is an example how to install additional PHP extensions
# Start by switch to root user
USER root

# Then add extension e.g. imagick
RUN install-php-extensions imagick

ENV COMPOSER_ALLOW_SUPERUSER=1

COPY app /app/app
COPY database /app/database
# COPY helpers /app/helpers/
COPY composer.json /app/composer.json
COPY composer.lock /app/composer.lock

WORKDIR /app

RUN composer install --prefer-dist --no-ansi --no-dev --no-interaction --no-progress --no-scripts --classmap-authoritative

#
# NPM Dependencies
#
FROM node:20-alpine AS npm

# Install pnpm with corepack
# RUN npm install --global corepack@latest

# RUN corepack enable pnpm

RUN mkdir -p /app/public

COPY package.json vite.config.js package-lock.json /app/
# COPY public/js/ /app/public/js/
# COPY public/css/ /app/public/css/
COPY resources/ /app/resources/

WORKDIR /app

RUN npm install && npm run build

#
# Application container
#

FROM serversideup/php:8.3-fpm-nginx-alpine

# Add queue worker via s6 overlay
COPY --chmod=755 ./etc/s6-overlay/s6-rc.d/laravel-queue/ /etc/s6-overlay/s6-rc.d/laravel-queue/
COPY --chmod=755 ./etc/s6-overlay/s6-rc.d/user/contents.d/laravel-queue /etc/s6-overlay/s6-rc.d/user/contents.d/laravel-queue

# Set down signal TO SIGTERM
COPY --chmod=755 ./etc/s6-overlay/s6-rc.d/nginx/down-signal /etc/s6-overlay/s6-rc.d/nginx/down-signal
COPY --chmod=755 ./etc/s6-overlay/s6-rc.d/php-fpm/down-signal /etc/s6-overlay/s6-rc.d/php-fpm/down-signal

# This is an example how to install additional PHP extensions
# Start by switch to root user
USER root

# Then add extension e.g. imagick
RUN install-php-extensions imagick

USER www-data

# Copies the Laravel app, but skips the ignored files and paths
COPY --chown=www-data:www-data . .
COPY --chown=www-data:www-data --from=vendor /app/vendor/ /var/www/html/vendor/
COPY --chown=www-data:www-data --from=npm /app/public/ /var/www/html/public/

ENV AUTORUN_ENABLED="true" \
    AUTORUN_LARAVEL_MIGRATION="true" \
    AUTORUN_LARAVEL_MIGRATION_ISOLATION="true" \
    PHP_OPCACHE_ENABLE="1"
