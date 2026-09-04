FROM alpine:3.20

RUN apk add --no-cache \
    php83 php83-fpm php83-mysqli php83-json php83-session php83-mbstring \
    php83-gd php83-curl php83-xml php83-zip php83-opcache php83-phar \
    php83-dom php83-fileinfo php83-tokenizer php83-iconv \
    curl tar bash mariadb-client \
    && ln -sf /usr/bin/php83 /usr/bin/php

WORKDIR /var/www/html

COPY conf/www.conf /etc/php83/php-fpm.d/www.conf
COPY conf/php.ini /etc/php83/conf.d/99-custom.ini
COPY tools/setup.sh /usr/local/bin/wp-entrypoint.sh
RUN chmod +x /usr/local/bin/wp-entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wp-entrypoint.sh"]
CMD ["php-fpm83", "-F"]