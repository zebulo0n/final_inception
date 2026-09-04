*This project has been created as part of the 42 curriculum by zoeschne.*

# Inception

## Description

Inception sets up a small, self-built infrastructure with Docker Compose: an
NGINX reverse proxy terminating TLS, a WordPress site running on php-fpm, and
a MariaDB database, each in its own container built from a hand-written
Dockerfile (no pre-built images from Docker Hub other than the base Alpine
image). The goal is to practice containerizing a real multi-service stack the
way it is done in production: isolated services, a private network,
persistent named volumes, and secrets kept out of the images and out of git.

The bonus part adds a Redis object cache for WordPress, an FTP server exposing
the WordPress files, a small static website, Adminer for database
administration, and an automated nightly MariaDB backup service.

## Instructions

1. Add `<your-login>.42.fr` to your `/etc/hosts` pointing at your VM's IP.
2. Replace every occurrence of `wil` (login, domain, `DATA_PATH`) in
   `srcs/.env`, `Makefile` and `srcs/docker-compose*.yml` with your own login.
3. Fill in real passwords in `secrets/*.txt` (these files are git-ignored;
   never commit real credentials).
4. Build and start the mandatory stack:
   ```
   make
   ```
5. Build and start the mandatory stack **and** the bonus services:
   ```
   make bonus
   ```
6. Visit `https://<login>.42.fr` (self-signed certificate, browser will warn).
7. Stop everything: `make down`. Full cleanup, including local volume data:
   `make fclean`.

See `USER_DOC.md` for day-to-day usage and `DEV_DOC.md` for the developer
setup in more detail.

## Project description: Docker, sources, and design choices

Every image is built from a per-service Dockerfile under
`srcs/requirements/<service>/`, called from `docker-compose.yml`/
`docker-compose.bonus.yml`, which are in turn driven by the root `Makefile`.
Configuration files (NGINX, php-fpm, MariaDB, Redis, vsftpd) are copied into
the images at build time; only real secrets are injected at runtime.

- **Virtual Machines vs Docker** — A VM virtualizes an entire machine
  (kernel included), which gives strong isolation but costs a lot of memory,
  disk, and startup time. A Docker container shares the host kernel and only
  packages the application and its dependencies, so it starts in
  milliseconds and uses a fraction of the resources. The trade-off is a
  slightly weaker isolation boundary than a VM. This project runs its
  containers inside one VM: the VM isolates the whole project from the host,
  and Docker isolates each service from the others inside that VM.

- **Secrets vs Environment Variables** — Environment variables set directly
  in `docker-compose.yml`/`.env` are visible to anyone with `docker inspect`
  access and can leak into logs or crash dumps. Docker secrets are mounted
  as read-only files under `/run/secrets/` inside the container, are never
  part of the image layers, and are not shown by `docker inspect`. Here,
  non-sensitive configuration (domain, usernames, feature flags) lives in
  `.env`, while every password lives in a secret file.

- **Docker Network vs Host Network** — `network: host` shares the host's
  network namespace directly, so containers see (and can collide with) every
  port on the host, and inter-container traffic isn't isolated at all. A
  user-defined bridge network (used here) gives containers their own private
  network with DNS-based service discovery (`mariadb`, `wordpress`, `nginx`
  resolve by container name) and only the explicitly published ports (443,
  plus the bonus ports) reach the host.

- **Docker Volumes vs Bind Mounts** — A bind mount just maps an arbitrary
  host path into a container; the host controls permissions and layout, and
  it's easy to accidentally delete or version-control that path. A named
  volume is managed by Docker itself, is portable across containers, and
  survives container recreation cleanly. This project uses named volumes
  (`wp_data`, `db_data`) configured with the `local` driver's bind options so
  the underlying files are still visible under `/home/<login>/data`, as the
  subject requires, while Docker still owns the volume lifecycle.

## Resources


- Whats is docker ?
https://www.geeksforgeeks.org/devops/difference-between-docker-and-virtualization/
https://www.geeksforgeeks.org/devops/30-days-of-docker/
https://www.datacamp.com/tutorial/docker-tutorial

- nginx
https://www.geeksforgeeks.org/operating-systems/what-is-nginx-web-server-and-how-to-install-it/
https://www.datacamp.com/tutorial/nginx-docker?dc_referrer=https%3A%2F%2Fwww.google.com%2F
SSL/TSL config 
https://nginx.org/en/docs/http/configuring_https_servers.html

- network interfaces
https://www.baeldung.com/linux/network-interface-configure

- HTTP/FTP proxy
https://www.fortinet.com/fr/resources/cyberglossary/proxy-server
https://success.skyhighsecurity.com/Skyhigh_Secure_Web_Gateway_(On-Prem)/Secure_Web_Gateway_Product_Guide/Proxies/FTP_Proxy/Best_practices_-_Configuring_FTP_over_HTTP

- TLS/SSL protocol
https://www.ibm.com/docs/en/sdk-java-technology/8?topic=provider-tls-protocol-overview

- docker compose
https://blog.stephane-robert.info/docs/conteneurs/orchestrateurs/docker-compose/
https://www.educative.io/blog/docker-compose-tutorial#Docker-Client



- Docker Compose specification: https://docs.docker.com/compose/compose-file/
- Docker Secrets: https://docs.docker.com/engine/swarm/secrets/
- NGINX SSL/TLS termination guide: https://nginx.org/en/docs/http/configuring_https_servers.html
- WP-CLI handbook: https://make.wordpress.org/cli/handbook/
- MariaDB Docker entrypoint reference (Alpine packages): https://mariadb.com/kb/en/
- vsftpd configuration reference: https://security.appspot.com/vsftpd.html
