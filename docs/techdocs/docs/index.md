# WebGrip Organisation Public

Welcome to the complete knowledge base for the WebGrip Organisation Public Repository. This site provides an end-to-end map of our platform infrastructure, operational procedures, and development workflows.

## What is This Repository?

The WebGrip Organisation Public Repository serves as the **foundational platform infrastructure** for the WebGrip organisation. It contains:

- **Base organizational structure** with domains, groups, and users
- **Kubernetes platform components** for container orchestration  
- **Infrastructure tooling** for deployment, monitoring, and operations
- **CI/CD workflows** for automated deployment and testing
- **Backstage catalog entities** for service discovery and documentation

## Quick Navigation

### 🏗️ [Platform Architecture](platform/infrastructure_overview.md)
Understand our Kubernetes-based infrastructure, networking, and core platform components.

### ⚙️ [Operations](operations/deployment_guide.md)  
Learn about CI/CD workflows, deployment procedures, secrets management, and operational tools.

### 📋 [Catalog Structure](catalog/domains.md)
Explore our Backstage catalog with domains, systems, components, and resources.

### 🛠️ [Development](development/local_setup.md)
Get started with local development, contribution guidelines, and testing procedures.

### 📚 [ADRs](adrs/overview.md)
Review architectural decisions that shape our platform design and implementation.

## Key Technologies

- **Container Orchestration**: Kubernetes with DOKS (DigitalOcean Kubernetes Service)
- **Ingress Controller**: Traefik v3.3.4 for traffic routing and load balancing
- **CI/CD**: GitHub Actions with self-hosted runners (ARC)
- **Monitoring**: Grafana stack with Prometheus for observability
- **Secrets Management**: Age + SOPS for encrypted configuration
- **Service Catalog**: Backstage for service discovery and documentation

## Getting Started

1. **New to the platform?** Start with [Getting Started](overview/getting_started.md)
2. **Want to contribute?** Check out [Local Setup](development/local_setup.md)
3. **Need to deploy something?** Review [Deployment Guide](operations/deployment_guide.md)
4. **Looking for a specific component?** Browse the [Catalog Structure](catalog/domains.md)

> **Note**: ADRs (Architectural Decision Records) are maintained in [`/docs/adrs/`](https://github.com/webgrip/organisation-public/tree/main/docs/adrs) in the repository. The [ADRs section](adrs/overview.md) provides links and context for these decisions.

## Support & Contribution

- **Issues**: Report problems via [GitHub Issues](https://github.com/webgrip/organisation-public/issues)
- **Contributions**: Follow our [Contributing Guidelines](development/contributing.md)
- **Maintenance**: See [Maintenance Guide](reference/maintenance.md) for keeping docs current
