FROM alpine:3.20

RUN apk add --no-cache nginx openssl \
    && mkdir -p /etc/nginx/ssl /run/nginx /var/www/html

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/gen-cert.sh /usr/local/bin/gen-cert.sh
RUN chmod +x /usr/local/bin/gen-cert.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/gen-cert.sh"]
CMD ["nginx", "-g", "daemon off;"]