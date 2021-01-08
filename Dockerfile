FROM php:7-apache

# Copy the testing files to www root
COPY src/ /var/www/html/

# Set defaults for variables used by run.sh
ENV COMPOSER_HOME=/root/.composer

RUN apt-get update -q -y \
    && apt-get install -q -y --no-install-recommends \
        ca-certificates \
        curl \
        acl \
        sudo \
# Needed for the php extensions we enable below
        libfreetype6 \
        libjpeg62-turbo \
        libxpm4 \
        libpng16-16 \
        libicu63 \
        libxslt1.1 \
        libzip4 \
        imagemagick \
        libonig5 \
# git & unzip needed for composer, unless we document to use dev image for composer install
# unzip needed due to https://github.com/composer/composer/issues/4471
        unzip \
        git

RUN set -xe \
    && buildDeps=" \
        $PHP_EXTRA_BUILD_DEPS \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libxpm-dev \
        libpng-dev \
        libicu-dev \
        libxslt1-dev \
        libmemcached-dev \
        libzip-dev \
        libxml2-dev \
        libonig-dev \
    " \
	&& apt-get update -q -y && apt-get install -q -y --no-install-recommends $buildDeps && rm -rf /var/lib/apt/lists/* \
# Extract php source and install missing extensions
    && docker-php-source extract \
    && docker-php-ext-configure mysqli --with-mysqli=mysqlnd \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ --with-xpm=/usr/include/ --enable-gd-jis-conv \
    && docker-php-ext-install exif gd mbstring intl xsl zip mysqli pdo_mysql soap bcmath
    
RUN curl -sS https://getcomposer.org/installer | \
    php -- --install-dir=/usr/local/bin --filename=composer \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN composer 

VOLUME /var/www/html/

EXPOSE 80