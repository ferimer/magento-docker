# Magento 2.4.2-p1 Requirements - https://devdocs.magento.com/guides/v2.4/install-gde/system-requirements.html

FROM php:7.4-apache AS InstallComposer
LABEL maintainer="Ferimer <devteam@ferimer.es>"

RUN sed -i 's/main/main contrib/g' /etc/apt/sources.list && \
    apt update && \
    apt dist-upgrade -y

# Install COMPOSER (https://getcomposer.org/download/)
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === '906a84df04cea2aa72f40b5f787e49f22d4c2f19492ac310e8cba5b96ac8b64115ac402c8cd292b8a03482574915d1a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

FROM php:7.4-apache AS Magento_2_4

COPY --from=InstallComposer /var/lib/apt /var/lib/apt
COPY --from=InstallComposer /etc/apt /etc/apt

COPY --from=InstallComposer /usr/local/bin/composer /usr/local/bin/composer

######################################################
# MAGENTO INSTALL
# https://devdocs.magento.com/guides/v2.4/install-gde/install-flow-diagram.html
######################################################

######################################################
# System Requirements
######################################################
RUN a2enmod rewrite && \
    docker-php-source extract

# ext-iconv
RUN docker-php-ext-install -j$(nproc) iconv

# ext-gd
RUN apt install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev && \
    docker-php-ext-configure gd \
      --with-freetype=/usr/include/ \
#      --with-png=/usr/include/ \ # No longer necessary as of 7.4; https://github.com/docker-library/php/pull/910#issuecomment-559383597
      --with-jpeg=/usr/include/ && \
    docker-php-ext-install -j$(nproc) gd

# ext-intl
RUN apt install -y zlib1g-dev libicu-dev g++ && \
    docker-php-ext-configure intl && \
    docker-php-ext-install intl

# ext-simplexml, ext-soap, xml, ext-xsl
RUN apt install -y libxml2-dev libxslt1-dev && \
    docker-php-ext-install simplexml soap xml xsl

# ext-zip
RUN apt install -y libzip-dev && \
    docker-php-ext-install zip

# ext-sockets (for php-amqplib)
RUN docker-php-ext-install sockets

# ext-pdo_mysql
RUN docker-php-ext-install -j$(nproc) mysqli pdo_mysql

# ext-bcmath
RUN docker-php-ext-install -j$(nproc) bcmath

######################################################
# Authentication keys
# https://devdocs.magento.com/guides/v2.4/install-gde/prereq/connect-auth.html
######################################################
ARG MAGENTO_USER
ARG MAGENTO_PASS

COPY composer_auth.template.json /var/www/.composer/auth.json
RUN sed -i "s/MAGENTO_USER/$MAGENTO_USER/" /var/www/.composer/auth.json && \
    sed -i "s/MAGENTO_PASS/$MAGENTO_PASS/" /var/www/.composer/auth.json && \
    chown -R www-data:www-data /var/www

######################################################
# Get Magento software dependencies
######################################################
RUN apt install -y zip

######################################################
# Cleaning
######################################################
RUN docker-php-source delete && \
    apt autoremove -y && \
    apt autoclean && \
    rm -rf /var/lib/apt/lists/*

######################################################
# Get Magento software (as www-data)
######################################################
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" && \
    sed -i 's/memory_limit = .*/memory_limit = 756M/' "$PHP_INI_DIR/php.ini" && \
    sed -i 's/max_execution_time = .*/max_execution_time = 18000/' "$PHP_INI_DIR/php.ini"

USER www-data
RUN composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition . && \
    echo "<?php phpinfo() ?>" > ferimer.php && \
    sed -i '/MariaDB-(10.2-10.4)/a <item name="MariaDB-(10.5.9)" xsi:type="string">^10\.5\.</item>' app/etc/di.xml && \
    rm /var/www/.composer/auth.json
