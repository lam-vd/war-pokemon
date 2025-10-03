# Docker Compose command - sử dụng Docker Compose V2
COMPOSE = docker compose

# Build all services
build:
	$(COMPOSE) build

# Start all services
up:
	$(COMPOSE) up -d

# Stop all services
down:
	$(COMPOSE) down

# Restart all services
restart:
	$(COMPOSE) restart

# View logs
logs:
	 $(COMPOSE) logs -f

# View logs for specific service
logs-web:
	 $(COMPOSE) logs -f web

logs-mysql:
	 $(COMPOSE) logs -f mysql

logs-redis:
	 $(COMPOSE) logs -f redis

# Rails console
console:
	 $(COMPOSE) exec web rails console

# Rails shell
shell:
	 $(COMPOSE) exec web bash

# Run tests
test:
	 $(COMPOSE) exec web rails test

# Bundle install
bundle:
	 $(COMPOSE) exec war-pokemon-web bundle install

# Database commands
db-create:
	 $(COMPOSE) exec war-pokemon-web rails db:create

db-migrate:
	 $(COMPOSE) exec war-pokemon-web rails db:migrate

db-seed:
	 $(COMPOSE) exec war-pokemon-web rails db:seed

db-reset:
	 $(COMPOSE) exec web rails db:reset

db-rollback:
	 $(COMPOSE) exec web rails db:rollback

# MySQL CLI
mysql:
	 $(COMPOSE) exec mysql mysql -u root -p

# Redis CLI
redis:
	 $(COMPOSE) exec redis redis-cli

# Generate Rails files
generate:
	 $(COMPOSE) exec web rails generate $(ARGS)

# Clean up
clean:
	 $(COMPOSE) down -v --rmi all

# Show status
status:
	 $(COMPOSE) ps

# Pull latest images
pull:
	 $(COMPOSE) pull

# Rebuild and restart everything
rebuild: down build up

.PHONY: build up down restart logs logs-web logs-mysql logs-redis console shell test bundle db-create db-migrate db-seed db-reset db-rollback mysql redis generate clean status pull rebuild