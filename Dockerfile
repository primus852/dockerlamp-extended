FROM ubuntu:18.04

MAINTAINER t3kit

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -yq \
    apt-utils \
    curl \
    # Install git
    git \
    # Install apache
    apache2 \
    # Install php 7.2
    libapache2-mod-php7.2 \
    php7.2-cli \
    php7.2-json \
    php7.2-curl \
    php7.2-fpm \
    php7.2-gd \
    php7.2-ldap \
    php7.2-mbstring \
    php7.2-mysql \
    php7.2-soap \
    php7.2-sqlite3 \
    php7.2-xml \
    php7.2-zip \
    php7.2-intl \
    php7.2-xdebug \
    php-imagick \
    # Install tools
    nano \
    wget \
    graphicsmagick \
    imagemagick \
    ghostscript \
    mysql-client \
    iputils-ping \
    node-gyp \
    nodejs-dev \
    libssl1.0-dev \
    nodejs \
    npm \
    zip \
    unzip \
    locales \
    && apt-get autoremove

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set locales
RUN locale-gen en_US.UTF-8 en_GB.UTF-8 de_DE.UTF-8 es_ES.UTF-8 fr_FR.UTF-8 it_IT.UTF-8 km_KH sv_SE.UTF-8 fi_FI.UTF-8

RUN a2enmod rewrite expires

# Update the PHP.ini file, enable <? ?> tags and quieten logging.
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php/7.2/apache2/php.ini
RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php/7.2/apache2/php.ini
RUN sed -ie 's/memory_limit\ =\ 128M/memory_limit\ =\ 2G/g' /etc/php/7.2/apache2/php.ini
RUN sed -ie 's/\;date\.timezone\ =/date\.timezone\ =\ Europe\/Berlin/g' /etc/php/7.2/apache2/php.ini
RUN sed -ie 's/upload_max_filesize\ =\ 2M/upload_max_filesize\ =\ 200M/g' /etc/php/7.2/apache2/php.ini
RUN sed -ie 's/post_max_size\ =\ 8M/post_max_size\ =\ 200M/g' /etc/php/7.2/apache2/php.ini

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

# Install PHPUnit
RUN wget https://phar.phpunit.de/phpunit.phar
RUN chmod +x phpunit.phar
RUN mv phpunit.phar /usr/local/bin/phpunit

# Install MailParse
# https://github.com/php-mime-mail-parser/php-mime-mail-parser
RUN apt-get update && apt-get install -yq \
	php-dev \
	php-pear \
	php7.2-imap
RUN cd
RUN pecl download mailparse && tar -xvf mailparse-3.0.3.tgz && cd mailparse-3.0.3 && phpize7.2 && ./configure && sed -i 's/#if\s!HAVE_MBSTRING/#ifndef MBFL_MBFILTER_H/' ./mailparse.c && make && mv modules/mailparse.so /usr/lib/php/20170718/
RUN echo "extension=mailparse.so" | tee /etc/php/7.2/mods-available/mailparse.ini
RUN phpenmod mailparse

# Install WKHTMLTOX
RUN apt install -yq \
	xfonts-base \
    xfonts-75dpi \
	fontconfig \
	libxrender1 \
    libxext6
RUN wget https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb && dpkg -i wkhtmltox_0.12.5-1.bionic_amd64.deb

WORKDIR /var/www/html

CMD ["apache2ctl", "-D", "FOREGROUND"]
