# Project Overview

## Purpose & Mission

The WebGrip Organisation Public Repository serves as the **foundational infrastructure platform** for the WebGrip organisation. This repository provides the essential building blocks needed to establish and manage the complete organizational structure in a cloud-native environment.

## Core Responsibilities

### Organizational Foundation
- **Domain Structure**: Defines business domains ([operations](../catalog/domains.md#operations-domain), [telemetry](../catalog/domains.md#telemetry-domain))
- **System Architecture**: Establishes core systems like [Kubernetes](../catalog/systems.md#kubernetes-system)
- **Component Catalog**: Manages platform components ([ingress-nginx](../catalog/components.md#ingress-nginx), [cert-manager](../catalog/components.md#cert-manager))
- **Resource Management**: Defines infrastructure resources ([staging cluster](../catalog/resources.md#staging-cluster))

### Platform Infrastructure
- **Container Orchestration**: Kubernetes cluster management and configuration
- **Ingress & Networking**: Traefik-based traffic routing and load balancing
- **Security & Compliance**: Certificate management and secrets encryption
- **Monitoring & Observability**: Grafana dashboards and Prometheus metrics

### Operational Excellence  
- **CI/CD Automation**: GitHub Actions workflows for deployment and testing
- **Infrastructure as Code**: Helm charts for consistent deployments
- **Secrets Management**: Age/SOPS encryption for secure configuration
- **Development Tools**: Local development setup and contribution workflows

## Repository Structure

> **Assumption**: The repository structure follows platform engineering best practices with clear separation of concerns.
> **Validation**: Review [Repository Structure](repository_structure.md) for detailed breakdown.

```
organisation-public/
├── catalog/           # Backstage catalog entities
│   ├── domains/       # Business domain definitions
│   ├── systems/       # System architecture components  
│   ├── components/    # Individual service components
│   └── resources/     # Infrastructure resources
├── ops/               # Operational tooling and configurations
│   ├── helm/          # Helm charts for deployments
│   └── secrets/       # Encrypted configuration files
├── docs/              # Documentation and ADRs
│   ├── adrs/          # Architectural Decision Records
│   └── techdocs/      # This documentation site
└── .github/           # CI/CD workflows and automation
```

## Key Stakeholders

- **Infrastructure Team**: Primary owners and maintainers
- **Platform Engineers**: Contributors and operators  
- **Development Teams**: Consumers of platform services
- **Operations Team**: Monitoring and incident response

## Success Metrics

The platform's effectiveness is measured by:

- **Deployment Frequency**: Time from commit to production deployment
- **Mean Time to Recovery (MTTR)**: Speed of incident resolution
- **Platform Adoption**: Number of services using platform components  
- **Developer Experience**: Time to first successful deployment for new team members

## Related Resources

- [Getting Started Guide](getting_started.md) - First steps for new users
- [Repository Structure](repository_structure.md) - Detailed file organization
- [Platform Architecture](../platform/infrastructure_overview.md) - Technical infrastructure details
- [Catalog Overview](../catalog/domains.md) - Service catalog structure

## Links to Source

- [README.md](../../README.md) - Repository introduction
- [catalog-info.yaml](../../catalog-info.yaml) - Backstage entity definitions
- [Makefile](../../Makefile) - Common operational commands