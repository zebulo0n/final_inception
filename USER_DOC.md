# User Documentation

## What services does this stack provide?

| Service | What it's for | How you reach it |
|---|---|---|
| NGINX | HTTPS entrypoint for the whole stack | `https://<login>.42.fr` |
| WordPress | The website / blog itself | via NGINX, same URL |
| MariaDB | Stores the WordPress content | internal only, not exposed |
| Redis (bonus) | Speeds up WordPress page loads | internal only |
| FTP (bonus) | Upload/download WordPress files | `ftp://<login>.42.fr:21` |
| Static site (bonus) | A small standalone page | `http://<login>.42.fr:8080` |
| Adminer (bonus) | Web UI to browse the database | `http://<login>.42.fr:8081` |
| Backup (bonus) | Nightly database dump | no interface, runs on its own |

## Starting and stopping the project

From the repository root:

- Start the mandatory services: `make`
- Start everything, including the bonus services: `make bonus`
- Stop the containers (keep data): `make stop`
- Start them again: `make start`
- Stop and remove the containers (keep data): `make down`
- Full reset, deletes all local data too: `make fclean`

## Accessing the website and the admin panel

- Website: open `https://<login>.42.fr` in a browser. The TLS certificate is
  self-signed, so the browser will show a warning the first time — this is
  expected for a local/school setup.
- Admin panel: go to `https://<login>.42.fr/wp-admin`. Log in with the
  administrator account (see below for where to find the password). Note the
  administrator's username intentionally does **not** contain the word
  "admin", per the project's requirements.
- A second, non-administrator WordPress account is also created for regular
  editing tasks.

## Locating and managing credentials

All passwords live in plain-text files under `secrets/` at the repository
root, one password per file:

- `secrets/db_root_password.txt` — MariaDB root password
- `secrets/db_password.txt` — password for the WordPress database user
- `secrets/credentials.txt` — WordPress administrator password
- `secrets/wp_user_password.txt` — WordPress second (non-admin) user password
- `secrets/ftp_password.txt` — FTP account password (bonus)

Non-sensitive settings (domain name, usernames, database name) are in
`srcs/.env`. **Never** commit real values in `secrets/*.txt` to git — they
are excluded via `.gitignore` on purpose.

## Checking that services are running correctly

- List running containers and their health: `make ps`
- Follow logs from every container: `make logs`
- Check a single container, e.g. WordPress: `docker logs -f wordpress`
- A container that keeps restarting usually means a misconfigured secret or
  a database that hasn't finished starting yet — check its logs first.