UID ?= $(shell id -u)
DOCKER_COMPOSE = env UID=$(UID) docker-compose -f docker-compose.yml

.PHONY: seed_public_key
seed_public_key:
	$(DOCKER_COMPOSE) up -d --build runner-app-service-token-cache-redis
	./bin/seed_test_public_key

.PHONY: build
build:
	$(DOCKER_COMPOSE) build --parallel

setup: build seed_public_key
