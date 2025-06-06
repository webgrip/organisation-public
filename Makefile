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

decrypt-secrets:
ifndef SECRETS_DIR
	$(error SECRETS_DIR is not set. Usage: make decrypt-secrets SECRETS_DIR=./path/to/secrets)
endif
	@echo "Decrypting secrets..."
	@SOPS_AGE_KEY="$$(cat ./age.agekey)" \
		sops --decrypt $(SECRETS_DIR)/values.sops.yaml > $(SECRETS_DIR)/values.dec.yaml

## View k8s cluster grafana dashboard
view-cluster-grafana:
	open -a "Brave Browser" http://localhost:3000 && kubectl port-forward -n kube-prometheus-stack svc/kube-prometheus-stack-grafana 3000:80
	@echo "Access Grafana at: http://localhost:3000 with username: admin"

## View grafana- dashboard
view-grafana:
	open -a "Brave Browser" http://localhost:3001 && kubectl port-forward -n grafana-stack svc/grafana 3001:80
	@echo "Access Grafana at: http://localhost:3000 with username: admin"

## View Traefik dashboard
view-traefik:
	kubectl port-forward -n ingress-traefik svc/traefik-dashboard 9000:9000
	@echo "Access Traefik dashboard at: http://localhost:9000"

view-akeyless-gateway:
	kubectl port-forward -n akeyless svc/akeyless-gateway 8000:8000
	@echo "Access Akeyless Gateway at: http://localhost:8000"
