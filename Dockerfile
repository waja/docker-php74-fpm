FROM php:7.4.22-fpm-alpine

ARG BUILD_DATE
ARG BUILD_VERSION
ARG VCS_URL
ARG VCS_REF
ARG VCS_BRANCH

# See http://label-schema.org/rc1/ and https://microbadger.com/labels
LABEL maintainer="Jan Wagner <waja@cyconet.org>" \
    org.label-schema.name="PHP 7.4 - FastCGI Process Manager" \
    org.label-schema.description="PHP-FPM 7.4 (with some more extensions installed)" \
    org.label-schema.vendor="Cyconet" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.build-date="${BUILD_DATE:-unknown}" \
    org.label-schema.version="${BUILD_VERSION:-unknown}" \
    org.label-schema.vcs-url="${VCS_URL:-unknown}" \
    org.label-schema.vcs-ref="${VCS_REF:-unknown}" \
    org.label-schema.vcs-branch="${VCS_BRANCH:-unknown}" \
    org.opencontainers.image.source="https://github.com/waja/docker-php74-fpm"

ENV EXT_DEPS \
  freetype \
  libpng \
  libjpeg-turbo \
  libwebp \
  freetype-dev \
  libpng-dev \
  libjpeg-turbo-dev \
  libwebp-dev \
  imagemagick-dev \
  libtool

# hadolint ignore=SC2086,DL3017,DL3018
RUN set -xe; \
  apk --no-cache update && apk --no-cache upgrade \
  && apk add --no-cache ${EXT_DEPS} \
  && apk add --no-cache --virtual .build-deps ${PHPIZE_DEPS} \
  && docker-php-ext-configure bcmath \
  && docker-php-ext-configure exif \
  && docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
  && pecl install imagick \
  && NPROC="$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1)" \
  && docker-php-ext-install "-j${NPROC}" bcmath exif gd mysqli \
  && docker-php-ext-enable bcmath exif gd imagick mysqli \
  && apk add --no-cache --virtual .imagick-runtime-deps imagemagick libgomp \
  # Cleanup build deps
  && apk del .build-deps \
  && rm -rf /tmp/* /var/cache/apk/*
