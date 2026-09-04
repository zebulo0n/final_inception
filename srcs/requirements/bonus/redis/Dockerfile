FROM alpine:3.20

RUN apk add --no-cache redis

COPY conf/redis.conf /etc/redis.conf

EXPOSE 6379

CMD ["redis-server", "/etc/redis.conf"]