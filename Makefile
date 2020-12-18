UID ?= $(shell id -u)
DOCKER_COMPOSE = env UID=$(UID) docker-compose -f docker-compose.yml

.PHONY: seed_public_key
seed_public_key:
	$(DOCKER_COMPOSE) up -d --build runner-app-service-token-cache-redis
	./bin/seed_test_public_key

.PHONY: build
build:
	$(DOCKER_COMPOSE) build --parallel

setup-integration: build seed_public_key

setup-ci:
	docker-compose -f docker-compose.ci.yml build

security-check:
	docker-compose -f docker-compose.ci.yml run --rm runner-app-ci bundle exec brakeman -q --no-pager

spec:
	docker-compose -f docker-compose.ci.yml run --rm runner-app-ci bundle exec rspec spec

