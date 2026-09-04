# Developer Documentation

## Setting up the environment from scratch

Prerequisites: a Linux VM with Docker Engine and the Compose plugin
(`docker compose version` should work), and `make`.

1. Clone the repository into the VM.
2. Replace every occurrence of the login `bobiw` with your own 42 login in:
   - `Makefile` (`LOGIN` variable)
   - `srcs/.env` (`DOMAIN_NAME`, `LOGIN`, `DATA_PATH`, and email addresses)
3. Point `<login>.42.fr` at the VM's IP, e.g. by adding a line to
   `/etc/hosts` on the host you browse from:
   ```
   <vm-ip>  <login>.42.fr
   ```
4. Fill in real values for every file in `secrets/` (one password per file,
   no quotes, no trailing content beyond the password itself). These files
   are `.gitignore`d and must stay that way.
5. `srcs/.env` only holds non-secret configuration (domain, usernames,
   database name, feature flags like `REDIS_ENABLED`). Nothing sensitive
   should ever go in there.

## Building and launching with the Makefile / Compose

- `make` — creates the host data directories, then builds and starts the
  mandatory services (`mariadb`, `wordpress`, `nginx`) via
  `srcs/docker-compose.yml`.
- `make bonus` — same, but also builds/starts `srcs/docker-compose_bonus.yml`
  (`redis`, `ftp`, `static-site`, `adminer`, `backup`), merged with the base
  file in the same Compose invocation so they share the `inception` network
  and the `wp_data` volume.
- `make build` — rebuild images without starting containers.
- `make down` / `make stop` / `make start` / `make restart` — standard
  lifecycle operations, always applied to both compose files together.
- `make logs` / `make ps` — inspect running containers.
- `make clean` — `down` + `docker system prune -af` (removes dangling images
  and build cache).
- `make fclean` — `clean` + delete `$(DATA_PATH)` on the host + prune unused
  volumes. **Destroys all WordPress/MariaDB data.**
- `make re` — `fclean` then `make` (full rebuild from a clean state).

Each service is built from its own Dockerfile under
`srcs/requirements/<service>/` (and `srcs/requirements/bonus/<service>/` for
bonus containers) — see the tree under `srcs/requirements/` for the full
layout of `Dockerfile`, `conf/`, and `tools/` per service.

## Useful commands for containers and volumes

- Rebuild a single service: `docker compose -f srcs/docker-compose.yml build nginx`
- Restart a single service: `docker compose -f srcs/docker-compose.yml restart wordpress`
- Shell into a running container: `docker exec -it wordpress sh`
- Inspect a named volume: `docker volume inspect wp_data`
- Inspect the network: `docker network inspect srcs_inception`
- Run a WP-CLI command directly: `docker exec wordpress wp plugin list --allow-root`

## Where project data lives and how it persists

- `wp_data` (WordPress core files, themes, plugins, uploads) is bind-backed
  by `${DATA_PATH}/wp_data`, i.e. `/home/<login>/data/wp_data` on the host.
- `db_data` (MariaDB's data directory) is bind-backed by
  `${DATA_PATH}/db_data`, i.e. `/home/<login>/data/db_data` on the host.
- `db_backups` (bonus) is bind-backed by `${DATA_PATH}/db_backups`.

Directory names on the host intentionally match the volume names 1:1 to
avoid the classic pitfall below.

Docker's `local` driver requires these host directories to already exist
*with matching names* before the volume is first created — `make`'s
`data_dirs` target creates them for you. If you ever see a
`failed to mount local volume: ... no such file or directory` error (for
example `mount /home/<login>/data/db_data: ... no such file or directory`),
it means the exact host path Compose is trying to bind doesn't exist yet.
Two ways to fix it:

1. Run `make data_dirs` (or `mkdir -p` the exact path shown in the error),
   then `make up` again — the empty volume will mount fine on the next try.
2. If the volume already exists but points at the wrong/missing path (e.g.
   after editing `DATA_PATH` or a device path post-first-run), Docker won't
   auto-update it: remove the stale volume first with
   `docker volume rm wp_data db_data` (make sure the containers are stopped),
   recreate the directories, then `make up`.

Because these are named volumes (not plain bind mounts), removing a
container never deletes this data — only `docker volume rm` / `make fclean`
does.
