# Makefile for ASP.NET Core Docker Application
# Provides standardized commands for development, testing, and deployment

.PHONY: help setup build up down clean dev logs shell test security lint check db-reset db-migrate db-shell k8s-build status env-check

# Default target
.DEFAULT_GOAL := help

# Variables
# Smart Docker Compose file selection based on available environment
COMPOSE_FILE := $(shell \
	if [ -f "deployments/compose/compose-localdb.yaml" ] && [ -f ".local" ]; then \
		echo "deployments/compose/compose-localdb.yaml"; \
	elif [ -f "deployments/compose/compose.yaml" ] && [ -f ".secret" ]; then \
		echo "deployments/compose/compose.yaml"; \
	else \
		echo "deployments/compose/compose-localdb.yaml"; \
	fi)

# Environment file selection
ENV_FILE := $(shell \
	if echo "$(COMPOSE_FILE)" | grep -q "localdb"; then \
		echo ".local"; \
	else \
		echo ".secret"; \
	fi)

# Container names based on compose file
APP_CONTAINER := $(shell \
	if echo "$(COMPOSE_FILE)" | grep -q "localdb"; then \
		echo "compose-frontend-1"; \
	else \
		echo "compose-server-1"; \
	fi)

APP_NAME := mywebapp
DB_CONTAINER := compose-mssql-1
SRC_DIR := src
BIN_DIR := bin

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
RED := \033[0;31m
NC := \033[0m # No Color

# Helper function to print colored output
define print_status
	@echo "$(BLUE)[INFO]$(NC) $(1)"
endef

define print_success
	@echo "$(GREEN)[SUCCESS]$(NC) $(1)"
endef

define print_warning
	@echo "$(YELLOW)[WARNING]$(NC) $(1)"
endef

define print_error
	@echo "$(RED)[ERROR]$(NC) $(1)"
endef

## Show this help message
help:
	@echo ""
	@echo "$(BLUE)ASP.NET Core Docker Application - Available Commands$(NC)"
	@echo ""
	@echo "$(GREEN)📊 Current Configuration:$(NC)"
	@echo "  Compose file: $(YELLOW)$(COMPOSE_FILE)$(NC)"
	@echo "  Environment:  $(YELLOW)$(ENV_FILE)$(NC)"
	@echo "  App container: $(YELLOW)$(APP_CONTAINER)$(NC)"
	@echo ""
	@echo "$(YELLOW)🚀 Development Lifecycle:$(NC)"
	@echo "  make setup          Setup development environment and validate config"
	@echo "  make build          Build Docker images"
	@echo "  make up             Start all services (auto-detects setup type)"
	@echo "  make down           Stop all services"
	@echo "  make clean          Stop services and remove volumes (destroys data)"
	@echo ""
	@echo "$(YELLOW)💻 Development Workflow:$(NC)"
	@echo "  make dev            Start database only, run webapp locally"
	@echo "  make logs           View service logs"
	@echo "  make shell          Interactive shell in webapp container"
	@echo "  make status         Show service status"
	@echo ""
	@echo "$(YELLOW)🗄️ Database Operations:$(NC)"
	@echo "  make db-reset       Reset database with fresh data"
	@echo "  make db-migrate     Run Entity Framework migrations"
	@echo "  make db-shell       Interactive SQL Server shell"
	@echo ""
	@echo "$(YELLOW)🧪 Quality Assurance:$(NC)"
	@echo "  make test           Run unit and integration tests"
	@echo "  make security       Run comprehensive security scans"
	@echo "  make lint           Run code linting and formatting"
	@echo "  make check          Run all quality checks (test + security + lint)"
	@echo ""
	@echo "$(YELLOW)☸️ Kubernetes Preparation:$(NC)"
	@echo "  make k8s-build      Build images for Kubernetes deployment"
	@echo "  make kubectl        Install kubectl for cluster management"
	@echo ""
	@echo "$(YELLOW)📋 Information:$(NC)"
	@echo "  make help           Show this help message"
	@echo ""

## Validate environment configuration
env-check:
	$(call print_status,"Validating environment configuration...")
	@if echo "$(COMPOSE_FILE)" | grep -q "localdb"; then \
		echo "$(GREEN)📋 Using: Full stack with local database$(NC)"; \
		if [ ! -f ".local" ]; then \
			$(call print_error,".local file required for local database setup"); \
			echo "$(YELLOW)💡 Create .local with SA_PASSWORD and MSSQL_SA_PASSWORD$(NC)"; \
			exit 1; \
		fi; \
	else \
		echo "$(GREEN)📋 Using: App-only setup$(NC)"; \
		if [ ! -f ".secret" ]; then \
			$(call print_error,".secret file required for app-only setup"); \
			echo "$(YELLOW)💡 Create .secret with CS_MSSQL_CONN$(NC)"; \
			exit 1; \
		fi; \
	fi
	$(call print_success,"Environment configuration validated")

## Setup development environment
setup: env-check
	$(call print_status,"Setting up development environment...")
	@if [ ! -f .local ]; then \
		echo "Creating .local environment file..."; \
		echo "SA_PASSWORD=SecurePass123!" > .local; \
		echo "MSSQL_SA_PASSWORD=SecurePass123!" >> .local; \
		chmod 600 .local; \
		$(call print_warning,"Default passwords created in .local - please customize them!"); \
	fi
	@if [ ! -f .local.sh ]; then \
		echo "Creating .local.sh environment file..."; \
		echo 'export SA_PASSWORD="SecurePass123!"' > .local.sh; \
		echo 'export MSSQL_SA_PASSWORD="SecurePass123!"' >> .local.sh; \
		chmod 600 .local.sh; \
	fi
	$(call print_success,"Environment setup complete!")
	$(call print_warning,"Remember to customize passwords in .local and .local.sh")

## Build Docker images
build:
	$(call print_status,"Building Docker images...")
	@cd deployments/compose && docker compose -f compose-localdb.yaml build
	$(call print_success,"Docker images built successfully!")

## Start all services
up: setup
	$(call print_status,"Starting all services...")
	@cd deployments/compose && docker compose -f compose-localdb.yaml up -d
	@echo ""
	$(call print_success,"Services started successfully!")
	@echo ""
	@echo "$(BLUE)🌐 Application URLs:$(NC)"
	@echo "  • Web App:  http://127.0.0.1:8080"
	@echo "  • Database: 127.0.0.1:1433"
	@echo ""
	@echo "$(BLUE)📋 Useful commands:$(NC)"
	@echo "  • Check status: make status"
	@echo "  • View logs:    make logs"
	@echo "  • Stop:         make down"

## Stop all services
down:
	$(call print_status,"Stopping all services...")
	@cd deployments/compose && docker compose -f compose-localdb.yaml down
	$(call print_success,"Services stopped!")

## Clean all services and volumes (destroys data)
clean:
	$(call print_warning,"This will destroy all database data!")
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read dummy
	$(call print_status,"Stopping services and removing volumes...")
	@cd deployments/compose && docker compose -f compose-localdb.yaml down -v
	@cd deployments/compose && docker compose -f compose-localdb.yaml down --remove-orphans
	$(call print_success,"Environment cleaned!")

## Start database only, run webapp locally
dev: setup
	$(call print_status,"Starting database for local development...")
	@cd deployments/compose && docker compose -f compose-localdb.yaml up mssql -d
	@echo ""
	$(call print_success,"Database started! Run the webapp locally:")
	@echo ""
	@echo "$(BLUE)📋 Next steps:$(NC)"
	@echo "  1. source .local.sh"
	@echo "  2. cd $(SRC_DIR)"
	@echo "  3. dotnet run"
	@echo ""
	@echo "$(BLUE)🗄️ Database connection:$(NC)"
	@echo "  • Host: 127.0.0.1:1433"
	@echo "  • SA Password: See .local file"

## View service logs
logs:
	$(call print_status,"Showing service logs...")
	@cd deployments/compose && docker compose -f compose-localdb.yaml logs -f

## Interactive shell in webapp container
shell:
	$(call print_status,"Opening shell in webapp container...")
	@if [ $$(cd deployments/compose && docker compose -f compose-localdb.yaml ps -q frontend | wc -l) -eq 0 ]; then \
		$(call print_error,"Webapp container not running. Use 'make up' first."); \
		exit 1; \
	fi
	@cd deployments/compose && docker compose -f compose-localdb.yaml exec frontend /bin/bash

## Show service status
status:
	$(call print_status,"Service Status:")
	@cd deployments/compose && docker compose -f compose-localdb.yaml ps
	@echo ""
	@if [ $$(cd deployments/compose && docker compose -f compose-localdb.yaml ps -q | wc -l) -gt 0 ]; then \
		echo "$(GREEN)✅ Services are running$(NC)"; \
		echo ""; \
		echo "$(BLUE)🌐 Access URLs:$(NC)"; \
		echo "  • Web Application: http://127.0.0.1:8080"; \
		echo "  • Database Server: 127.0.0.1:1433"; \
	else \
		echo "$(YELLOW)⚠️  No services running$(NC)"; \
		echo ""; \
		echo "$(BLUE)💡 Start services with:$(NC)"; \
		echo "  make up    # Full environment"; \
		echo "  make dev   # Database only"; \
	fi

## Reset database with fresh data
db-reset: 
	$(call print_warning,"This will destroy all database data!")
	@echo "Press Ctrl+C to cancel, or Enter to continue..."
	@read dummy
	$(call print_status,"Resetting database...")
	@cd deployments/compose && docker compose -f compose-localdb.yaml restart mssql
	@echo "Waiting for database to be ready..."
	@sleep 10
	$(call print_success,"Database reset complete!")

## Run Entity Framework migrations
db-migrate:
	$(call print_status,"Running Entity Framework migrations...")
	@if [ ! -f .local.sh ]; then $(call print_error,".local.sh not found. Run 'make setup' first."); exit 1; fi
	@source .local.sh && cd $(SRC_DIR) && dotnet ef database update
	$(call print_success,"Database migrations completed!")

## Interactive SQL Server shell
db-shell:
	$(call print_status,"Opening SQL Server shell...")
	@if [ $$(cd deployments/compose && docker compose -f compose-localdb.yaml ps -q mssql | wc -l) -eq 0 ]; then \
		$(call print_error,"Database container not running. Use 'make up' or 'make dev' first."); \
		exit 1; \
	fi
	@if [ ! -f .local ]; then $(call print_error,".local file not found. Run 'make setup' first."); exit 1; fi
	@echo "$(BLUE)💡 Connecting to SQL Server...$(NC)"
	@echo "$(BLUE)💡 Use 'quit' to exit$(NC)"
	@cd deployments/compose && docker exec -it $(DB_CONTAINER) /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$$(grep SA_PASSWORD ../../.local | cut -d'=' -f2)"

## Run unit and integration tests
test:
	$(call print_status,"Running tests...")
	@if [ -d "$(SRC_DIR)/myWebApp.Tests" ]; then \
		cd $(SRC_DIR) && dotnet test --logger "console;verbosity=normal"; \
	else \
		$(call print_warning,"No tests found. Test project not yet created."); \
		echo "$(BLUE)💡 To add tests:$(NC)"; \
		echo "  1. cd $(SRC_DIR)"; \
		echo "  2. dotnet new xunit -n myWebApp.Tests"; \
		echo "  3. Add test files and run 'make test' again"; \
	fi

## Run comprehensive security scans
security:
	$(call print_status,"Running security scans...")
	@if [ -f "$(BIN_DIR)/security-scan.sh" ]; then \
		$(BIN_DIR)/security-scan.sh; \
	else \
		$(call print_error,"Security scan script not found at $(BIN_DIR)/security-scan.sh"); \
		exit 1; \
	fi
	$(call print_success,"Security scans completed!")

## Run code linting and formatting
lint:
	$(call print_status,"Running code linting...")
	@cd $(SRC_DIR) && dotnet format --verify-no-changes --verbosity normal
	$(call print_success,"Code linting completed!")

## Run all quality checks
check: test security lint
	$(call print_success,"All quality checks completed!")

## Build images for Kubernetes deployment
k8s-build:
	$(call print_status,"Building images for Kubernetes...")
	@docker build -t $(APP_NAME):latest .
	@docker tag $(APP_NAME):latest $(APP_NAME):$$(date +%Y%m%d-%H%M%S)
	$(call print_success,"Kubernetes images built!")
	@echo ""
	@echo "$(BLUE)🏷️ Available images:$(NC)"
	@docker images | grep $(APP_NAME)

## Install kubectl for Kubernetes management
kubectl:
	$(call print_status,"Installing kubectl...")
	@$(BIN_DIR)/install-kubectl.sh
	$(call print_success,"kubectl installation completed!")
