FROM php:$VERSION-fpm
MAINTAINER Mark Shust <mark.shust@mageinferno.com>

ENV TERM xterm

RUN apt-get update \
  && apt-get install -y \
    git \
    curl \
    nano \
    cron \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng12-dev \
    libxslt1-dev \    
  && apt-get clean

RUN docker-php-ext-configure \
  gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/

RUN docker-php-ext-install \
  gd \
  intl \
  mbstring \
  mcrypt \
  pdo_mysql \
  soap \
  xsl \
  zip

RUN curl -sS https://getcomposer.org/installer | \
  php -- --install-dir=/usr/local/bin --filename=composer 

RUN pecl install xdebug-beta && \
    docker-php-ext-enable xdebug && \
    touch /usr/local/etc/php/conf.d/xdebug.ini && \
    echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/xdebug.ini && \
    echo "xdebug.remote_autostart=1" >> /usr/local/etc/php/conf.d/xdebug.ini && \
    echo "xdebug.remote_host=192.168.20.107" >> /usr/local/etc/php/conf.d/xdebug.ini && \
    echo "xdebug.max_nesting_level=500" >> /usr/local/etc/php/conf.d/xdebug.ini
 
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash - \
 && apt-get -y install nodejs \
 && apt-get clean \
 && npm install -g grunt-cli
 

ENV PHP_MEMORY_LIMIT 2G
ENV PHP_PORT 9000
ENV PHP_PM dynamic
ENV PHP_PM_MAX_CHILDREN 10
ENV PHP_PM_START_SERVERS 4
ENV PHP_PM_MIN_SPARE_SERVERS 2
ENV PHP_PM_MAX_SPARE_SERVERS 6
ENV APP_MAGE_MODE default
ENV TERM xterm

COPY conf/www.conf /usr/local/etc/php-fpm.d/
COPY conf/php.ini /usr/local/etc/php/
COPY conf/php-fpm.conf /usr/local/etc/
COPY bin/* /usr/local/bin/

WORKDIR /var/www/html

CMD ["/usr/local/bin/start"]
