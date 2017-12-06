FROM php:7.0-fpm

LABEL maintainer="Sebastian König <skoenig@viosys.com>"

# install basics and php extensions
RUN apt-get update && \
    apt-get upgrade -y
RUN apt-get install -y \
      ca-certificates \
      libfreetype6 \
      libfreetype6-dev \
      git \
      ant \
      sudo \
      libicu-dev \
      libjpeg62-turbo \
      libjpeg62-turbo-dev \
      libmcrypt-dev \
      libpng12-0  \
      libpng12-dev \
      mysql-client \
      libpcre3-dev \
      unzip \
      wget \
      build-essential \
      coreutils \
      autoconf \
      automake && \
    docker-php-ext-configure gd \
      --with-gd \
      --with-freetype-dir=/usr/include/ \
      --with-png-dir=/usr/include/ \
      --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install -j$(nproc) \
      bcmath \
      gd \
      intl \
      mcrypt \
      mysqli \
      opcache \
      pdo_mysql \
      zip && \
    pecl install \
      apcu \
      redis \
      xdebug && \
    docker-php-ext-enable \
      apcu \
      redis && \
    rm -rf /tmp/pear && \
    apt-get remove build-essential -y && \
    update-ca-certificates && \
    ln -s /usr/local/bin/php /usr/bin/php && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# install ioncube
RUN cd /tmp \
	&& curl -o ioncube.tar.gz http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
    && tar -xvvzf ioncube.tar.gz \
    && mv ioncube/ioncube_loader_lin_7.0.so /usr/local/lib/php/extensions/* \
    && rm -Rf ioncube.tar.gz ioncube \
    && echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20151012/ioncube_loader_lin_7.0.so" > /usr/local/etc/php/conf.d/00_docker-php-ext-ioncube_loader_lin_7.0.ini


# install nginx
RUN apt-get install -y \
      nginx \
      supervisor && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    rm -rf /var/lib/nginx/tmp && \
    ln -sf /tmp /var/lib/nginx/tmp && \
    mkdir /etc/supervisor.d/ && \
    chown -R www-data:www-data /var/lib/nginx && \
    apt-get autoremove -y

# add config
RUN rm -f /etc/nginx/sites-available/* && \
    rm -f /etc/nginx/sites-enabled/* && \
    mkdir -p /etc/nginx/ssl/

COPY contfs/ /

RUN ln -sf /etc/nginx/sites-available/10-docker.conf /etc/nginx/sites-enabled/10-docker.conf

ONBUILD VOLUME /var/www/html

EXPOSE 443 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]