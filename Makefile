# Makefile for managing secrets encryption, Kubernetes tools, and dashboards

.PHONY: install-tools encrypt-secrets decrypt-secrets install-k9s install-kubectx deploy-helm view-grafana view-traefik

## Install age and sops
install-tools:
	brew install age sops kubectx derailed/k9s/k9s

## Encrypt values.yaml -> values.sops.yaml in the specified directory
encrypt-secrets:
ifndef SECRETS_DIR
	$(error SECRETS_DIR is not set. Usage: mamkke encrypt-secrets SECRETS_DIR=./path/to/secrets)
endif
	sops --encrypt --age $$(cat age.pubkey) $(SECRETS_DIR)/values.dec.yaml > $(SECRETS_DIR)/values.sops.yaml
	@echo "Encrypted: $(SECRETS_DIR)/values.dec.yaml -> $(SECRETS_DIR)/values.sops.yaml"

## Decrypt values.sops.yaml -> values.dec.yaml in the specified directory
decrypt-secrets:
ifndef SECRETS_DIR
	$(error SECRETS_DIR is not set. Usage: make decrypt-secrets SECRETS_DIR=./path/to/secrets)
endif
	sops --decrypt $(SECRETS_DIR)/values.sops.yaml > $(SECRETS_DIR)/values.dec.yaml
	@echo "Decrypted: $(SECRETS_DIR)/values.sops.yaml -> $(SECRETS_DIR)/values.dec.yaml"

## View Grafana dashboard
view-grafana:
	kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
	@echo "Access Grafana at: http://localhost:3000 with username: admin"

## View Traefik dashboard
view-traefik:
	kubectl port-forward -n traefik svc/traefik-dashboard 9000:9000
	@echo "Access Traefik dashboard at: http://localhost:9000"

view-akeyless-gateway:
	kubectl port-forward -n akeyless svc/akeyless-gateway 8000:8000
	@echo "Access Akeyless Gateway at: http://localhost:8000"