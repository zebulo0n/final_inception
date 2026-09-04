FROM alpine:3.20

RUN apk add --no-cache mariadb mariadb-client \
    && mkdir -p /run/mysqld /var/lib/mysql \
    && chown -R mysql:mysql /run/mysqld /var/lib/mysql

COPY conf/mariadb.conf /etc/my.cnf.d/50-server.cnf
COPY tools/setup.sh /usr/local/bin/mariadb-entrypoint.sh
RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/mariadb-entrypoint.sh"]