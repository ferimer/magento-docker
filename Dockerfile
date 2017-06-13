# Magento 2.1 Requirements - http://devdocs.magento.com/guides/v2.1/install-gde/system-requirements-tech.html

FROM php:7.0-apache
LABEL maintainer="Ferimer <devteam@ferimer.es>"

RUN sed -i 's/main/main contrib/g' /etc/apt/sources.list && \
    apt update && \
    apt dist-upgrade -y

# PHP Requirements: curl, gd, ImageMagick 6.3.7 (or later) or both, intl, mbstring, mcrypt
# mhash, openssl, PDO/MySQL, SimpleXML, soap, xml, xsl, zip, json, iconv

# openssl
RUN apt install -y openssl

# cURL
RUN apt install -y curl libcurl4-openssl-dev && docker-php-ext-install curl

# iconv, mcrypt & gd
RUN apt install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
    && docker-php-ext-install -j$(nproc) iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

# intl
RUN apt install -y zlib1g-dev libicu-dev g++ \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl

# ImageMagick
RUN apt install -y libmagickwand-dev \
    && pecl install imagick && docker-php-ext-enable imagick

# mbstring, PDO/MySQL, json
RUN docker-php-ext-install mbstring pdo_mysql json

# simplexml, soap, xml, xsl
RUN apt install -y libxml2-dev libxslt1-dev \
    && docker-php-ext-install simplexml soap xml xsl

# zip
RUN apt install -y zlib1g-dev \
    && docker-php-ext-install zip

# mhash
RUN docker-php-ext-configure hash --with-mhash

# PHP Config
COPY resources/php.ini /usr/local/etc/php/

# Magento distribution
COPY resources/Magento-CE-2.1.7-2017-05-30-02-18-42.tar.bz2 /opt/
COPY resources/scripts/* /opt/

# Setup Apache
RUN a2enmod rewrite

