# =============================================================================
# Application Makefile
# -----------------------------------------------------------------------------
# Usage: make <target>
# Run `make help` to see all available targets.
# =============================================================================

# --- Core config --------------------------------------------------------------

SHELL := /usr/bin/bash
.ONESHELL:
.DEFAULT_GOAL := help

# Tools (override if needed, e.g., COMPOSE="docker-compose")
COMPOSE ?= docker compose
DC ?= $(COMPOSE)  # Alias for convenience

# Services / paths
APP_SERVICE ?= firefly-iii-application.application
ENV_FILE    ?= .env.app

# Helm / SOPS / AGE defaults (override at call time if you want)
HELM_CHART_DIR ?=
SECRETS_DIR    ?= ./secrets
AGE_KEY        ?= ./age.agekey
AGE_PUB        ?= ./age.pubkey
SOPS_FILE      ?= values.sops.yaml
DECRYPT_FILE   ?= values.dec.yaml

# Colors for nicer output
C_RESET := \033[0m
C_OK    := \033[32m
C_WARN  := \033[33m
C_ERR   := \033[31m
C_INFO  := \033[36m

# --- Helpers -----------------------------------------------------------------

define _req_cmd
	@if ! command -v $(1) >/dev/null 2>&1; then \
		printf "$(C_ERR)Missing dependency: $(1)$(C_RESET)\n"; \
		exit 1; \
	fi
endef

define _req_file
	@if [ ! -f "$(1)" ]; then \
		printf "$(C_ERR)Missing required file: $(1)$(C_RESET)\n"; \
		exit 1; \
	fi
endef

## Print a variable: make print-VAR VAR=NAME
print-VAR:
	@printf "$(C_INFO)%s=$(C_RESET)%s\n" "$(VAR)" "$($(VAR))"

# --- Top-level UX -------------------------------------------------------------

## Show available commands (this help)
help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nCommands:\n"} \
	/^[a-zA-Z0-9_.-]+:.*##/ { printf "  \033[36m%-24s\033[0m %s\n", $$1, $$2 } \
	END {print ""}' $(MAKEFILE_LIST)

# --- Docker lifecycle ---------------------------------------------------------

## Start containers in background
start:
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	$(COMPOSE) --env-file ./.env.app --env-file ./.env.importer up -d
	@printf "$(C_OK)Started containers.$(C_RESET)\n"

## Stop and remove containers
stop:
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	$(COMPOSE) --env-file ./.env.app --env-file ./.env.importer down
	@printf "$(C_OK)Stopped containers.$(C_RESET)\n"

## Alias for docker compose (shorter command)
dc:  ## Alias for docker compose commands
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	@test -n "$$CMD" || { printf "$(C_ERR)Usage: make dc CMD=\"<docker-compose command>\"$(C_RESET)\n"; exit 1; }
	$(COMPOSE) --env-file ./.env.app --env-file ./.env.importer $$CMD

## Check environment file loading
check-env:  ## Check if environment files are being loaded correctly
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	@printf "$(C_INFO)Checking environment file loading...$(C_RESET)\n"
	@printf "$(C_INFO)Current directory: $(shell pwd)$(C_RESET)\n"
	@printf "$(C_INFO)Env files present:$(C_RESET)\n"
	@ls -la .env* 2>/dev/null || echo "  No .env files found"
	@printf "$(C_INFO)Testing config:$(C_RESET)\n"
	$(COMPOSE) --env-file ./.env.app --env-file ./.env.importer config --quiet 2>&1 | head -10 || echo "  Config check failed"

## Full rebuild: stop, remove orphans/volumes, rebuild and start
rebuild:  ## Full rebuild: stop containers, remove orphans and volumes, rebuild images, start
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	@printf "$(C_WARN)Stopping containers and removing orphans...$(C_RESET)\n"
	$(COMPOSE) --env-file ./.env.app --env-file ./.env.importer down --remove-orphans --volumes
	@printf "$(C_INFO)Rebuilding images...$(C_RESET)\n"
	$(COMPOSE) --env-file ./.env.app --env-file ./.env.importer build --no-cache
	@printf "$(C_OK)Starting containers...$(C_RESET)\n"
	$(COMPOSE) --env-file ./.env.app --env-file ./.env.importer up -d
	@printf "$(C_OK)Rebuild complete.$(C_RESET)\n"

## Quick rebuild without volume removal (safer)
rebuild-quick:  ## Quick rebuild: stop, rebuild images, restart (keeps volumes)
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	@printf "$(C_WARN)Stopping containers...$(C_RESET)\n"
	$(COMPOSE) --env-file ./.env.app --env-file ./.env.importer down
	@printf "$(C_INFO)Rebuilding images...$(C_RESET)\n"
	$(COMPOSE) --env-file ./.env.app --env-file ./.env.importer build --no-cache
	@printf "$(C_OK)Starting containers...$(C_RESET)\n"
	$(COMPOSE) --env-file ./.env.app --env-file ./.env.importer up -d
	@printf "$(C_OK)Quick rebuild complete.$(C_RESET)\n"

## Full reset: stop containers with orphans/volumes removal, then rebuild and start
reset:  ## Full reset: dc down --remove-orphans --volumes && dc up --build
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	@printf "$(C_WARN)Stopping containers and removing orphans/volumes...$(C_RESET)\n"
	$(COMPOSE) --env-file ./.env.app --env-file ./.env.importer down --remove-orphans --volumes
	@printf "$(C_OK)Starting containers with rebuild...$(C_RESET)\n"
	$(COMPOSE) --env-file ./.env.app --env-file ./.env.importer up --build -d
	@printf "$(C_OK)Full reset complete.$(C_RESET)\n"

## Follow logs (all services or SERVICE=name)
logs:
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	@if [ -n "$$SERVICE" ]; then \
		printf "$(C_INFO)Following logs for %s...$(C_RESET)\n" "$$SERVICE"; \
		$(COMPOSE) logs -f $$SERVICE; \
	else \
		printf "$(C_INFO)Following logs (all services)...$(C_RESET)\n"; \
		$(COMPOSE) logs -f; \
	fi

## Exec into the app container (CMD=/bin/sh or e.g. CMD="/bin/bash -lc 'env | sort'")
enter:
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	: $${CMD:=/bin/sh}
	$(COMPOSE) exec $(APP_SERVICE) $$CMD

## Run an arbitrary command in a one-off app container: e.g. make run CMD="php -v"
run:
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	@test -n "$$CMD" || { printf "$(C_ERR)Usage: make run CMD=\"...\"$(C_RESET)\n"; exit 1; }
	$(COMPOSE) run --rm $(APP_SERVICE) $$CMD

# --- Firefly III Management Commands -----------------------------------------

## Apply rules and rule groups on transactions
firefly-apply-rules:  ## Apply rules and rule groups on transactions
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	@printf "$(C_INFO)Applying rules...$(C_RESET)\n"
	$(COMPOSE) exec $(APP_SERVICE) php artisan firefly-iii:apply-rules

## Validate and correct database integrity
firefly-correct-database:  ## Validate and correct database integrity
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	@printf "$(C_INFO)Correcting database integrity...$(C_RESET)\n"
	$(COMPOSE) exec $(APP_SERVICE) php artisan firefly-iii:correct-database

## Run all Firefly III cron-job commands
firefly-cron:  ## Run all Firefly III cron-job commands
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	@printf "$(C_INFO)Running Firefly III cron jobs...$(C_RESET)\n"
	$(COMPOSE) exec $(APP_SERVICE) php artisan firefly-iii:cron

## Export data from Firefly III
firefly-export-data:  ## Export data from Firefly III
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	@printf "$(C_INFO)Exporting data...$(C_RESET)\n"
	$(COMPOSE) exec $(APP_SERVICE) php artisan firefly-iii:export-data

## Generate Laravel Passport keys
firefly-laravel-passport-keys:  ## Generate Laravel Passport keys
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	@printf "$(C_INFO)Generating Laravel Passport keys...$(C_RESET)\n"
	$(COMPOSE) exec $(APP_SERVICE) php artisan firefly-iii:laravel-passport-keys

## Output Firefly III version
firefly-output-version:  ## Output Firefly III version
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	@printf "$(C_INFO)Firefly III version:$(C_RESET)\n"
	$(COMPOSE) exec $(APP_SERVICE) php artisan firefly-iii:output-version

## Report on database integrity
firefly-report-integrity:  ## Report on database integrity
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	@printf "$(C_INFO)Reporting database integrity...$(C_RESET)\n"
	$(COMPOSE) exec $(APP_SERVICE) php artisan firefly-iii:report-integrity

## Reset error mail limit
firefly-reset-error-mail-limit:  ## Reset error mail limit
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	@printf "$(C_INFO)Resetting error mail limit...$(C_RESET)\n"
	$(COMPOSE) exec $(APP_SERVICE) php artisan firefly-iii:reset-error-mail-limit

## Rescan attachments and reset MD5 hash and mime
firefly-scan-attachments:  ## Rescan attachments and reset MD5 hash and mime
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	@printf "$(C_INFO)Scanning attachments...$(C_RESET)\n"
	$(COMPOSE) exec $(APP_SERVICE) php artisan firefly-iii:scan-attachments

## Set latest version in database
firefly-set-latest-version:  ## Set latest version in database
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	@printf "$(C_INFO)Setting latest version...$(C_RESET)\n"
	$(COMPOSE) exec $(APP_SERVICE) php artisan firefly-iii:set-latest-version

## Upgrade database to latest version
firefly-upgrade-database:  ## Upgrade database to latest version
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	@printf "$(C_INFO)Upgrading database...$(C_RESET)\n"
	$(COMPOSE) exec $(APP_SERVICE) php artisan firefly-iii:upgrade-database

## Verify security alerts
firefly-verify-security-alerts:  ## Verify security alerts
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	@printf "$(C_INFO)Verifying security alerts...$(C_RESET)\n"
	$(COMPOSE) exec $(APP_SERVICE) php artisan firefly-iii:verify-security-alerts

## Generate fresh Laravel APP_KEY and Importer key (overwrites in .env.app and .env.importer)
gen-keys:
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	@printf "$(C_INFO)Generating application APP_KEY...$(C_RESET)\n"
	APP_KEY_LINE=$$($(COMPOSE) run --rm $(APP_SERVICE) php -r 'echo base64_encode(random_bytes(32));'); \
	sed -i "s|^APP_KEY=.*|APP_KEY=base64:$$APP_KEY_LINE=|" .env.app; \
	printf "$(C_OK)Updated APP_KEY in .env.app$(C_RESET)\n"; \
	printf "$(C_INFO)Generating importer APP_KEY...$(C_RESET)\n"; \
	IMPORTER_KEY_LINE=$$($(COMPOSE) run --rm firefly-iii-application.importer php -r 'echo base64_encode(random_bytes(32));'); \
	sed -i "s|^IMPORTER_APP_KEY=.*|IMPORTER_APP_KEY=base64:$$IMPORTER_KEY_LINE=|" .env.importer; \
	printf "$(C_OK)Updated IMPORTER_APP_KEY in .env.importer$(C_RESET)\n"; \
	printf "$(C_INFO)Keys regenerated. Restart containers to apply (make start).$(C_RESET)\n"

# --- Kubernetes commands ---------------------------------------------------

## Port forward application service
expose: ## Expose application service
	@$(call _req_cmd,kubectl)
	kubectl -n firefly-iii-application port-forward service/firefly-iii-application 8080:8080
	@printf "$(C_OK)Port forwarded to http://localhost:8080$(C_RESET)\n"

# --- Helm workflow ------------------------------------------------------------

## Initialize helm chart: update deps & lint (HELM_CHART_DIR=./charts/app)
init-helm:  ## Initialize Helm chart (deps + lint)
	@$(call _req_cmd,helm)
	@test -n "$(HELM_CHART_DIR)" || { \
		printf "$(C_ERR)HELM_CHART_DIR is not set. Usage: make init-helm HELM_CHART_DIR=./path/to/chart$(C_RESET)\n"; \
		exit 1; }
	@printf "$(C_INFO)Initializing Helm chart in %s...$(C_RESET)\n" "$(HELM_CHART_DIR)"
	helm dependency update "$(HELM_CHART_DIR)"
	helm lint "$(HELM_CHART_DIR)"
	@printf "$(C_OK)Helm chart initialized.$(C_RESET)\n"

# --- Secrets encryption (SOPS + age) -----------------------------------------

## Generate age keypair (writes $(AGE_KEY) and $(AGE_PUB))
init-encrypt:  ## Generate age keypair for SOPS
	@$(call _req_cmd,age-keygen)
	age-keygen > "$(AGE_KEY)"
	@printf "$(C_OK)Generated age key: %s$(C_RESET)\n" "$(AGE_KEY)"
	# Extract public key line to $(AGE_PUB)
	sed -n 's/^# public key:[[:space:]]*//p' "$(AGE_KEY)" > "$(AGE_PUB)"
	@printf "$(C_OK)Public key written to: %s$(C_RESET)\n" "$(AGE_PUB)"

## Encrypt secrets: $(SECRETS_DIR)/$(DECRYPT_FILE) -> $(SECRETS_DIR)/$(SOPS_FILE)
encrypt-secrets:  ## Encrypt secrets with SOPS (requires $(AGE_PUB))
	@$(call _req_cmd,sops)
	@$(call _req_file,$(AGE_PUB))
	@test -n "$(SECRETS_DIR)" || { \
		printf "$(C_ERR)SECRETS_DIR is not set. Usage: make encrypt-secrets SECRETS_DIR=./path/to/secrets$(C_RESET)\n"; \
		exit 1; }
	@$(call _req_file,$(SECRETS_DIR)/$(DECRYPT_FILE))
	PUB="$$(cat "$(AGE_PUB)")"
	sops --encrypt --age "$$PUB" \
		"$(SECRETS_DIR)/$(DECRYPT_FILE)" > "$(SECRETS_DIR)/$(SOPS_FILE)"
	@printf "$(C_OK)Encrypted: %s -> %s$(C_RESET)\n" \
		"$(SECRETS_DIR)/$(DECRYPT_FILE)" "$(SECRETS_DIR)/$(SOPS_FILE)"

## Decrypt secrets: $(SECRETS_DIR)/$(SOPS_FILE) -> $(SECRETS_DIR)/$(DECRYPT_FILE)
decrypt-secrets:  ## Decrypt secrets with SOPS (requires $(AGE_KEY))
	@$(call _req_cmd,sops)
	@$(call _req_file,$(AGE_KEY))
	@test -n "$(SECRETS_DIR)" || { \
		printf "$(C_ERR)SECRETS_DIR is not set. Usage: make decrypt-secrets SECRETS_DIR=./path/to/secrets$(C_RESET)\n"; \
		exit 1; }
	@$(call _req_file,$(SECRETS_DIR)/$(SOPS_FILE))
	printf "$(C_INFO)Decrypting secrets...$(C_RESET)\n"
	SOPS_AGE_KEY="$$(cat "$(AGE_KEY)")" \
		sops --decrypt "$(SECRETS_DIR)/$(SOPS_FILE)" > "$(SECRETS_DIR)/$(DECRYPT_FILE)"
	@printf "$(C_OK)Decrypted -> %s$(C_RESET)\n" "$(SECRETS_DIR)/$(DECRYPT_FILE)"

# --- Extras -------------------------------------------------------------------

## Quick health probe (customize to your app): URL=http://localhost:8080/health
wait-ready:  ## Poll a URL until HTTP 200 (URL=...)
	@$(call _req_cmd,curl)
	@test -n "$$URL" || { printf "$(C_ERR)Set URL=<probe url>$(C_RESET)\n"; exit 1; }
	@printf "$(C_INFO)Waiting for %s ...$(C_RESET)\n" "$$URL"
	for i in $$(seq 1 60); do \
		code=$$(curl -sk -o /dev/null -w '%{http_code}' "$$URL"); \
		if [ "$$code" = "200" ]; then printf "$(C_OK)Ready!$(C_RESET)\n"; exit 0; fi; \
		sleep 2; \
	done; \
	printf "$(C_ERR)Timeout waiting for %s$(C_RESET)\n" "$$URL"; exit 1

# --- Application key management ----------------------------------------------

## Show application key (non-mutating)
app-key-show:  ## Show the application key as reported by the app
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	$(COMPOSE) run --rm $(APP_SERVICE) php artisan key:generate --show

## Generate (rotate) application key inside the running app
app-key-generate:  ## Rotate app key in-container and update dependent state
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	$(COMPOSE) exec $(APP_SERVICE) php artisan key:generate --force
	$(COMPOSE) exec $(APP_SERVICE) php artisan ninja:update-key

## Generate an APP_KEY and persist to local .env.app (idempotent)
app-key-set:  ## Generate APP_KEY and write it to .env.app
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	@printf "$(C_INFO)Generating APP_KEY and updating .env.app...$(C_RESET)\n"
	@$(call _req_file,.env.app)
	NEW_KEY=$$(docker compose run --rm --no-deps $(APP_SERVICE) php artisan key:generate --show); \
	if grep -q '^APP_KEY=' .env.app; then \
	  sed -i.bak -E "s|^APP_KEY=.*|APP_KEY=$${NEW_KEY}|" .env.app; \
	  echo "Replaced existing APP_KEY (backup .env.app.bak)"; \
	else \
	  printf '\nAPP_KEY=%s\n' "$$NEW_KEY" >> .env.app; \
	  echo "Appended APP_KEY to end of .env.app"; \
	fi;

# --- Testing & Validation Commands --------------------------------------------

## Run all available tests (unit, integration, e2e)
test-all:  ## Run all available tests (unit, integration, e2e)
	@$(call _req_cmd,$(word 1,$(COMPOSE)))
	@printf "$(C_INFO)Running all test suites...$(C_RESET)\n"
	./tests/run-all-tests.sh

## Run unit tests only
test-unit:  ## Run unit tests only
	@printf "$(C_INFO)Running unit tests...$(C_RESET)\n"
	./tests/unit-tests.sh

## Run comprehensive setup validation
test-setup:  ## Run comprehensive setup validation
	@printf "$(C_INFO)Running setup validation...$(C_RESET)\n"
	./tests/validate-complete-setup.sh

## Run end-to-end tests with Playwright (using webgrip/playwright-runner:latest)
test-e2e:  ## Run end-to-end tests with Playwright
	@printf "$(C_INFO)Running E2E tests...$(C_RESET)\n"
	./tests/run-e2e-tests.sh

## Run E2E tests in headed mode (visible browser)
test-e2e-headed:  ## Run E2E tests in headed mode (visible browser)
	@printf "$(C_INFO)Running E2E tests in headed mode...$(C_RESET)\n"
	./tests/run-e2e-tests.sh --headed

## Run E2E tests with interactive UI
test-e2e-ui:  ## Run E2E tests with interactive UI
	@printf "$(C_INFO)Running E2E tests with UI...$(C_RESET)\n"
	./tests/run-e2e-tests.sh --ui

## Install E2E test dependencies (pull webgrip/playwright-runner:latest)
test-e2e-install:  ## Install E2E test dependencies
	@printf "$(C_INFO)Installing E2E test dependencies...$(C_RESET)\n"
	./tests/run-e2e-tests.sh --install

## Validate documentation links
test-links:  ## Validate documentation links
	@printf "$(C_INFO)Validating documentation links...$(C_RESET)\n"
	./check_links.sh

## Run service validation (if services are running)
test-services:  ## Run service validation (if services are running)
	@printf "$(C_INFO)Running service validation...$(C_RESET)\n"
	./validate-services.sh

# --- Phony list ---------------------------------------------------------------

.PHONY: \
  help start stop dc check-env rebuild rebuild-quick reset logs enter run \
	init-helm init-encrypt encrypt-secrets decrypt-secrets \
	create-firefly-user list-firefly-users delete-firefly-user \
	firefly-migrate firefly-migrate-rollback firefly-seed \
	firefly-cache-clear firefly-cache-rebuild \
	firefly-about firefly-verify firefly-upgrade \
	firefly-import firefly-export firefly-schedule-run firefly-commands \
	firefly-apply-rules firefly-correct-database \
	firefly-cron firefly-export-data \
	firefly-laravel-passport-keys \
	firefly-output-version firefly-report-integrity \
	firefly-reset-error-mail-limit firefly-scan-attachments firefly-set-latest-version \
	firefly-upgrade-database firefly-verify-security-alerts \
  app-key-show app-key-generate app-key-set \
	wait-ready print-VAR expose \
	test-all test-unit test-setup test-e2e test-e2e-headed test-e2e-ui test-e2e-install \
	test-links test-services


