UID ?= $(shell id -u)
DOCKER_COMPOSE = env UID=$(UID) docker-compose -f docker-compose.yml

.PHONY: setup
setup: build seed_public_key

.PHONY: seed_public_key
seed_public_key:
	$(DOCKER_COMPOSE) up -d --build runner-app-service-token-cache-redis
	./bin/seed_test_public_key

.PHONY: build
build:
	$(DOCKER_COMPOSE) build --parallel

.PHONY: setup-integration
setup-integration: build seed_public_key

.PHONY: setup-ci
setup-ci:
	docker-compose -f docker-compose.ci.yml build

.PHONY: security-check
security-check:
	docker-compose -f docker-compose.ci.yml run --rm runner-app-ci bundle exec brakeman -q --no-pager

.PHONY: lint
lint:
	docker-compose -f docker-compose.ci.yml run --rm runner-app-ci bundle exec rubocop

.PHONY: spec
spec:
	docker-compose -f docker-compose.ci.yml run --rm runner-app-ci bundle exec rspec

.PHONY: assets
assets:
	yarn install
	bundle exec rails assets:precompile
	./bin/webpack
