NAME       = inception
LOGIN      = bobiw
DATA_PATH  = /home/$(LOGIN)/data
COMPOSE    = docker compose -f srcs/docker-compose.yml --env-file srcs/.env
COMPOSE_B  = docker compose -f srcs/docker-compose.yml -f srcs/docker-compose_bonus.yml --env-file srcs/.env

.PHONY: all up bonus build down start stop restart logs ps clean fclean re data_dirs

all: up

up: data_dirs
	$(COMPOSE) up -d --build

bonus: data_dirs
	$(COMPOSE_B) up -d --build

build: data_dirs
	$(COMPOSE) build

down:
	$(COMPOSE_B) down

start:
	$(COMPOSE_B) start

stop:
	$(COMPOSE_B) stop

restart: down up

logs:
	$(COMPOSE_B) logs -f

ps:
	$(COMPOSE_B) ps

clean: down
	docker system prune -af

fclean: clean
	sudo rm -rf $(DATA_PATH)
	docker volume prune -f

re: fclean all

data_dirs:
	mkdir -p $(DATA_PATH)/wordpress
	mkdir -p $(DATA_PATH)/mariadb
	mkdir -p $(DATA_PATH)/backups
	mkdir -p $(DATA_PATH)/db_data
	mkdir -p $(DATA_PATH)/wp_data