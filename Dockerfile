#syntax=docker/dockerfile:1.4

ARG PHP_VERSION=8.3


FROM mlocati/php-extension-installer:latest AS php_extension_installer

FROM php:${PHP_VERSION}-fpm-alpine

WORKDIR /srv/app

COPY --from=php_extension_installer --link /usr/bin/install-php-extensions /usr/local/bin/

RUN apk add --no-cache $PHPIZE_DEPS git build-base zsh shadow

RUN set -eux; \
    install-php-extensions xsl intl zip apcu opcache pdo_pgsql 

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY --link docker/app.ini $PHP_INI_DIR/conf.d/
COPY --link docker/app.prod.ini $PHP_INI_DIR/conf.d/

# Symfony cli
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.alpine.sh' | sh && \
  apk add symfony-cli && \
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
