#!/bin/sh
set -e

CERT_DIR=/etc/nginx/ssl
DOMAIN=${DOMAIN_NAME:-localhost}

if [ ! -f "$CERT_DIR/inception.crt" ]; then
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout "$CERT_DIR/inception.key" \
        -out "$CERT_DIR/inception.crt" \
        -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=Inception/CN=${DOMAIN}"
fi

exec "$@"