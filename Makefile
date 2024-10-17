DOCKER_COMPOSE_PATH_PROD = .docker/docker-compose.prod.yml

DOCKER_COMPOSE_PATH_DEV = .docker/docker-compose.dev.yml

help:
	@echo "Commandes disponibles :"
	@echo "  make build   - Construire les images Docker définies dans docker-compose.yml"
	@echo "  make up      - Lancer les services en arrière-plan"
	@echo "  make down    - Arrêter les services"
	@echo "  make logs    - Afficher les logs des services en cours"
	@echo "  make ps      - Afficher l'état des services"
	@echo "  make web_shell - Ouvrir un shell dans le conteneur web"
	@echo "  make migrate - Lancer les migrations de la base de données"

up: build
	docker compose -f $(DOCKER_COMPOSE_PATH_PROD) up -d

down:
	docker compose -f $(DOCKER_COMPOSE_PATH_PROD) down

logs:
	docker compose -f $(DOCKER_COMPOSE_PATH_PROD) logs -f

web_shell:
	docker exec -it time_manager_web /bin/sh

db_shell:
	docker exec -it time_manager_db psql -U gotham_admin -d time_manager

migrate:
	docker compose exec -T web mix ecto.migrate

deps:
	cd ./time_manager && mix deps.get && cd ..

frontend_deps:
	cd ./frontend && npm install && cd ..

build: deps frontend_deps
	docker compose -f $(DOCKER_COMPOSE_PATH_PROD) build

up_dev: build_dev
	docker compose -f $(DOCKER_COMPOSE_PATH_DEV) up -d

down_dev:
	docker compose -f $(DOCKER_COMPOSE_PATH_DEV) down


logs_dev:
	docker compose -f $(DOCKER_COMPOSE_PATH_DEV) logs -f


build_dev: deps frontend_deps
	docker compose -f $(DOCKER_COMPOSE_PATH_DEV) build


.PHONY: help up down logs web_shell db_shell migrate deps frontend_deps build


