#!/bin/bash
set -e
export WP_CLI_PHP_ARGS="-d memory_limit=512M"

WP_PATH=/var/www/html

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/credentials)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

if [ ! -f /usr/local/bin/wp ]; then
    curl -o /usr/local/bin/wp -sSL \
        https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x /usr/local/bin/wp
fi

echo "Waiting for MariaDB..."
until mysqladmin ping -h mariadb -u"$MYSQL_USER" -p"$DB_PASSWORD" --silent 2>/dev/null; do
    sleep 2
done

if [ ! -f "$WP_PATH/wp-load.php" ]; then
    wp core download --path="$WP_PATH" --allow-root

    wp config create \
        --path="$WP_PATH" \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="mariadb:3306" \
        --allow-root

    # Administrator account - username deliberately avoids "admin"/"administrator"
    wp core install \
        --path="$WP_PATH" \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    # Second, non-administrator account
    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
        --role=editor \
        --user_pass="${WP_USER_PASSWORD}" \
        --path="$WP_PATH" \
        --allow-root

    if [ "${REDIS_ENABLED}" = "true" ]; then
        wp config set WP_REDIS_HOST redis --path="$WP_PATH" --allow-root
        wp config set WP_REDIS_PORT 6379 --raw --path="$WP_PATH" --allow-root
        wp plugin install redis-cache --activate --path="$WP_PATH" --allow-root || true
        wp redis enable --path="$WP_PATH" --allow-root || true
    fi

    chown -R nobody:nobody "$WP_PATH"
fi

exec "$@"
