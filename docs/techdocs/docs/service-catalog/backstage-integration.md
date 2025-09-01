# Backstage Integration

The WebGrip platform leverages **[Backstage](https://backstage.io/)** as the central **service catalog and developer portal**, providing a unified view of all services, APIs, teams, and infrastructure components across the organization.

## Backstage Overview

**Technology**: Backstage (Open Source Developer Portal)
**Entity Definitions**: [`catalog/`](../../../../catalog/)
**TechDocs Integration**: [`backstage.io/techdocs-ref: dir:./docs/techdocs`](../../../../catalog-info.yaml)

Backstage serves as the **organizational brain** of the platform, providing:

- **📋 Service Catalog**: Centralized inventory of all software components
- **👥 Team Directory**: Organization structure and ownership mapping  
- **📚 Documentation Hub**: Integrated TechDocs and API documentation
- **🔍 Service Discovery**: Find services, APIs, and their relationships
- **📊 Platform Overview**: Unified view of the entire software ecosystem

## Architecture

### Backstage Entity Model

```mermaid
erDiagram
    DOMAIN ||--o{ SYSTEM : contains
    SYSTEM ||--o{ COMPONENT : includes
    COMPONENT ||--o{ API : exposes
    COMPONENT ||--o{ RESOURCE : depends-on
    GROUP ||--o{ USER : contains
    GROUP ||--o{ COMPONENT : owns
    GROUP ||--o{ SYSTEM : owns
    
    DOMAIN {
        string name
        string description
        string owner
        string type
    }
    
    SYSTEM {
        string name
        string description
        string owner
        string domain
    }
    
    COMPONENT {
        string name
        string type
        string lifecycle
        string owner
        string system
    }
    
    API {
        string name
        string type
        string definition
        string owner
    }
    
    RESOURCE {
        string name
        string type
        string owner
        string environment
    }
    
    GROUP {
        string name
        string type
        string profile
        array children
        array members
    }
```

### Platform Integration

```mermaid
flowchart TB
    subgraph "Repository Structure"
        CATALOG[catalog/]
        DOMAINS[domains/]
        SYSTEMS[systems/]
        COMPONENTS[components/]
        GROUPS[groups/]
        RESOURCES[resources/]
    end
    
    subgraph "Backstage Entities"
        DOM_ENT[Domain Entities]
        SYS_ENT[System Entities]
        COMP_ENT[Component Entities]
        GROUP_ENT[Group Entities]
        RES_ENT[Resource Entities]
    end
    
    subgraph "Platform Services"
        K8S[Kubernetes Cluster]
        HELM[Helm Charts]
        GITHUB[GitHub Actions]
        TECHDOCS[TechDocs Site]
    end
    
    DOMAINS --> DOM_ENT
    SYSTEMS --> SYS_ENT
    COMPONENTS --> COMP_ENT
    GROUPS --> GROUP_ENT
    RESOURCES --> RES_ENT
    
    DOM_ENT --> K8S
    SYS_ENT --> HELM
    COMP_ENT --> GITHUB
    COMP_ENT --> TECHDOCS
```

## Entity Definitions

### Organization Structure

**Location**: [`catalog-info.yaml`](../../../../catalog-info.yaml)

The catalog-info.yaml file serves as the **entry point** for Backstage discovery:

```yaml
# Main catalog locations
apiVersion: backstage.io/v1alpha1
kind: Location
metadata:
  name: webgrip-domains
  namespace: webgrip
  description: A collection of all the domains within the WebGrip organisation
spec:
  targets:
    - ./catalog/domains/operations-domain.yaml
    - ./catalog/domains/telemetry-domain.yaml
```

**Entity Categories**:
- **Domains**: [`catalog/domains/`](../../../../catalog/domains/) - Business domain boundaries
- **Systems**: [`catalog/systems/`](../../../../catalog/systems/) - Technical system groupings
- **Components**: [`catalog/components/`](../../../../catalog/components/) - Individual services and applications
- **Groups**: [`catalog/groups/`](../../../../catalog/groups/) - Team and organizational structure
- **Resources**: [`catalog/resources/`](../../../../catalog/resources/) - Infrastructure resources

### Domain Definitions

**Purpose**: Define business domain boundaries and ownership

**Example**: [`catalog/domains/operations-domain.yaml`](../../../../catalog/domains/operations-domain.yaml)

```yaml
apiVersion: backstage.io/v1alpha1
kind: Domain
metadata:
  name: operations-domain
  namespace: webgrip
  title: Operations
  description: |
    The operations domain is responsible for all things having to do with operations
  labels:
    tier: "2"
  annotations:
    github.com/project-slug: webgrip/operations-domain
    backstage.io/techdocs-ref: dir:.
    simpleicons.org/icon-slug: rotaryinternational
  tags:
    - operations
    - infrastructure
  links:
    - url: http://example.com/domain/operations/
      title: Readme
      icon: book
      type: website
spec:
  owner: group:infrastructure
  type: product-area
```

**Domain Structure**:
| Domain | Purpose | Owner | Components |
|--------|---------|-------|------------|
| **[Operations](../../../../catalog/domains/operations-domain.yaml)** | Infrastructure & platform operations | Infrastructure Team | Kubernetes, Ingress, Monitoring |
| **[Telemetry](../../../../catalog/domains/telemetry-domain.yaml)** | Observability & monitoring | Platform Team | Grafana, Prometheus, Alerting |

### System Definitions

**Purpose**: Group related components into logical technical systems

**Example**: [`catalog/systems/kubernetes.yaml`](../../../../catalog/systems/kubernetes.yaml)

```yaml
apiVersion: backstage.io/v1alpha1
kind: System
metadata:
  name: kubernetes-system
  namespace: webgrip
  title: Kubernetes
  description: |
    Kubernetes is an open-source container-orchestration system for automating 
    application deployment, scaling, and management.
spec:
  owner: group:webgrip/infrastructure
  domain: webgrip/operations-domain
```

**System Hierarchy**:
```mermaid
flowchart TD
    OPS[Operations Domain] --> K8S[Kubernetes System]
    OPS --> GHA[GitHub Actions System]
    TEL[Telemetry Domain] --> MON[Monitoring System]
    
    K8S --> INGRESS[Ingress Components]
    K8S --> CERT[Certificate Components]
    K8S --> RUNNER[Runner Components]
    
    MON --> PROM[Prometheus Components]
    MON --> GRAF[Grafana Components]
```

### Component Definitions

**Purpose**: Catalog individual services, applications, and platform components

**Example**: [`catalog/components/ingress-nginx.yaml`](../../../../catalog/components/ingress-nginx.yaml)

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: ingress-nginx-component
  namespace: webgrip
  title: Ingress Nginx
  description: |
    Ingress Nginx is an Ingress controller for Kubernetes using NGINX as a reverse proxy and load balancer.
  labels:
    tier: "2"
  annotations:
    backstage.io/adr-location: docs/adr
    backstage.io/kubernetes-label-selector: "app.kubernetes.io/instance=ingress-nginx"
    backstage.io/kubernetes-namespace: ingress-nginx
    backstage.io/techdocs-ref: dir:.
    github.com/project-slug: kubernetes/ingress-nginx
    simpleicons.org/icon-slug: nginx
spec:
  type: service
  owner: group:webgrip/infrastructure
  lifecycle: experimental
  system: kubernetes-system
  dependsOn:
    - resource:webgrip/staging-doks-cluster
```

**Component Types**:
- **service**: Running applications and platform services
- **library**: Shared code libraries and packages
- **website**: Static websites and documentation sites

**Lifecycle Stages**:
- **experimental**: Early development and testing
- **production**: Stable, production-ready services
- **deprecated**: Services being phased out

### Group Definitions

**Purpose**: Define team structure and ownership hierarchy

**Example**: [`catalog/groups/c-level-group.yaml`](../../../../catalog/groups/c-level-group.yaml)

```yaml
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: c-level-group
  namespace: webgrip
  title: C-Level
  description: The C-Level group is responsible for the overall strategy and direction of the company.
  labels:
    tier: "1"
  annotations:
    github.com/project-slug: webgrip/organisation-public
    simpleicons.org/icon-slug: protodotio
spec:
  type: department
  profile:
    displayName: C-Level
    email: ryan@webgrip.nl
    picture: https://api.dicebear.com/7.x/identicon/svg?seed=Fluffy&backgroundColor=ffdfbf
  children: ['group:webgrip/infrastructure']
  members: ['Ryangr0']
```

**Organizational Hierarchy**:
```mermaid
flowchart TD
    CLEVEL[C-Level Group] --> INFRA[Infrastructure Group]
    INFRA --> PLATFORM[Platform Team]
    INFRA --> SECURITY[Security Team]
    INFRA --> DEVOPS[DevOps Team]
```

### Resource Definitions

**Purpose**: Catalog infrastructure resources and external dependencies

**Example**: [`catalog/resources/staging-doks-cluster.yaml`](../../../../catalog/resources/staging-doks-cluster.yaml)

```yaml
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: staging-doks-cluster
  namespace: webgrip
  title: Staging DOKS Cluster
  description: DigitalOcean Kubernetes cluster for staging workloads
spec:
  type: kubernetes-cluster
  owner: group:webgrip/infrastructure
  environment: staging
```

**Resource Types**:
- **kubernetes-cluster**: Kubernetes clusters and environments
- **database**: Database instances and services  
- **queue**: Message queues and event systems
- **storage**: File systems and object storage

## Annotations and Integrations

### Key Annotations

Backstage entities use annotations to integrate with external systems:

| Annotation | Purpose | Example |
|------------|---------|---------|
| `github.com/project-slug` | Link to GitHub repository | `webgrip/organisation-public` |
| `backstage.io/techdocs-ref` | TechDocs source location | `dir:./docs/techdocs` |
| `backstage.io/kubernetes-label-selector` | Kubernetes resource selector | `app.kubernetes.io/instance=traefik` |
| `backstage.io/kubernetes-namespace` | Kubernetes namespace | `ingress-traefik` |
| `simpleicons.org/icon-slug` | Display icon | `kubernetes` |

### TechDocs Integration

**This Repository**: [`catalog-info.yaml`](../../../../catalog-info.yaml)

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: organisation-public
  namespace: webgrip
  annotations:
    backstage.io/techdocs-ref: dir:./docs/techdocs
spec:
  type: platform
  owner: group:webgrip/infrastructure
```

**TechDocs Features**:
- **Automatic Publishing**: Docs published on every commit to main branch
- **Search Integration**: Full-text search across all documentation
- **Version Control**: Documentation versioned with code
- **Navigation**: Integrated navigation within Backstage interface

### Kubernetes Integration

Components can be linked to Kubernetes resources for real-time status:

```yaml
annotations:
  backstage.io/kubernetes-label-selector: "app.kubernetes.io/name=traefik"
  backstage.io/kubernetes-namespace: ingress-traefik
```

This enables:
- **Real-time Status**: Pod health and deployment status
- **Resource Metrics**: CPU, memory, and network usage
- **Log Access**: Direct access to container logs
- **Scaling Controls**: Scale deployments from Backstage interface

## Service Discovery

### Catalog Navigation

**Entity Relationships**: Backstage automatically maps relationships between entities:

```mermaid
flowchart LR
    subgraph "Domain Level"
        OPS_DOM[Operations Domain]
    end
    
    subgraph "System Level"  
        K8S_SYS[Kubernetes System]
        GHA_SYS[CI/CD System]
    end
    
    subgraph "Component Level"
        TRAEFIK[Traefik Ingress]
        CERT[cert-manager]
        RUNNERS[GHA Runners]
    end
    
    subgraph "Resource Level"
        CLUSTER[DOKS Cluster]
        SECRETS[Secret Store]
    end
    
    OPS_DOM --> K8S_SYS
    OPS_DOM --> GHA_SYS
    K8S_SYS --> TRAEFIK
    K8S_SYS --> CERT
    GHA_SYS --> RUNNERS
    TRAEFIK --> CLUSTER
    CERT --> CLUSTER
    RUNNERS --> SECRETS
```

### Search and Discovery

**Search Capabilities**:
- **Full-text Search**: Search across names, descriptions, and documentation
- **Tag-based Filtering**: Filter by technology, team, or environment
- **Owner-based Views**: See all components owned by a specific team
- **Dependency Mapping**: Understand component dependencies and impacts

**Common Search Patterns**:
```
# Find all infrastructure components
tag:infrastructure

# Find components owned by infrastructure team
owner:group:infrastructure

# Find experimental services
lifecycle:experimental

# Find components in specific domain
domain:operations-domain
```

## Ownership and Governance

### Ownership Model

**Ownership Hierarchy**:
```mermaid
flowchart TD
    DOMAIN[Domain Owner] --> SYSTEM[System Owner]
    SYSTEM --> COMPONENT[Component Owner]
    
    subgraph "Responsibilities"
        DOMAIN_RESP[Strategic Direction<br/>Architecture Decisions<br/>Resource Allocation]
        SYSTEM_RESP[System Integration<br/>API Contracts<br/>Performance SLAs]
        COMP_RESP[Implementation<br/>Maintenance<br/>Bug Fixes]
    end
    
    DOMAIN --> DOMAIN_RESP
    SYSTEM --> SYSTEM_RESP
    COMPONENT --> COMP_RESP
```

**Owner Types**:
- **group:webgrip/infrastructure**: Platform and infrastructure components
- **group:webgrip/security**: Security-related components and policies
- **group:webgrip/c-level**: Strategic and organizational components

### Component Lifecycle

**Lifecycle Management**:
```mermaid
stateDiagram-v2
    [*] --> experimental
    experimental --> production
    production --> deprecated
    deprecated --> [*]
    
    experimental : Experimental
    production : Production
    deprecated : Deprecated
    
    note right of experimental
        Early development
        Active testing
        Breaking changes allowed
    end note
    
    note right of production
        Stable and reliable
        SLA commitments
        Backward compatibility
    end note
    
    note right of deprecated
        Legacy system
        Migration planned
        Limited support
    end note
```

## Platform Components Catalog

### Current Component Inventory

| Component | Type | Owner | System | Status |
|-----------|------|-------|---------|---------|
| **[Ingress Nginx](../../../../catalog/components/ingress-nginx.yaml)** | service | infrastructure | kubernetes-system | experimental |
| **[cert-manager](../../../../catalog/components/cert-manager.yaml)** | service | infrastructure | kubernetes-system | production |
| **[Echo Service](../../../../catalog/components/echo.yaml)** | service | infrastructure | kubernetes-system | experimental |
| **[Quote Service](../../../../catalog/components/quote.yaml)** | service | infrastructure | kubernetes-system | experimental |
| **[Metrics Server](../../../../catalog/components/metrics-server.yaml)** | service | infrastructure | kubernetes-system | production |

### Component Dependencies

```mermaid
flowchart TD
    CLUSTER[DOKS Cluster] --> INGRESS[Ingress Controller]
    CLUSTER --> CERT[cert-manager]
    CLUSTER --> METRICS[Metrics Server]
    
    INGRESS --> ECHO[Echo Service]
    INGRESS --> QUOTE[Quote Service]
    CERT --> INGRESS
    
    ECHO --> METRICS
    QUOTE --> METRICS
```

## Best Practices

### Entity Definition Guidelines

**1. Descriptive Metadata**:
```yaml
metadata:
  title: "Human-readable title"
  description: |
    Multi-line description explaining:
    - Purpose and functionality
    - Key features
    - Integration points
```

**2. Comprehensive Annotations**:
```yaml
annotations:
  github.com/project-slug: "owner/repository"
  backstage.io/techdocs-ref: "dir:./docs"
  backstage.io/kubernetes-namespace: "namespace"
```

**3. Clear Ownership**:
```yaml
spec:
  owner: "group:webgrip/team-name"  # Always use group references
  lifecycle: "production|experimental|deprecated"
```

**4. Relationship Mapping**:
```yaml
spec:
  system: "parent-system"
  dependsOn:
    - "component:other-service"
    - "resource:database"
```

### Maintenance Guidelines

**Regular Updates**:
- **Quarterly Review**: Verify entity accuracy and relationships
- **Lifecycle Updates**: Promote experimental to production, mark deprecated
- **Ownership Changes**: Update owners when teams reorganize
- **Link Validation**: Ensure all external links remain valid

**Documentation Standards**:
- **TechDocs**: Every component should have linked documentation
- **API Docs**: Services should include OpenAPI specifications
- **Runbooks**: Operational procedures documented and linked

## Next Steps

Explore related service catalog topics:

<div class="grid cards" markdown>

-   🏗️ **[Domains & Systems](domains-systems.md)**
    
    Understand domain boundaries and system organization

-   📋 **[Component Registry](component-registry.md)**
    
    Explore individual service and component details

-   🔌 **[API Contracts](api-contracts.md)**
    
    Review API documentation and service contracts

-   👥 **[Team Structure](../governance-standards/operational-standards.md#team-structure)**
    
    Learn about team organization and responsibilities

</div>

---

> **📋 Catalog Maintenance**: Entity definitions should be updated whenever component ownership, lifecycle, or dependencies change. See [Operational Standards](../governance-standards/operational-standards.md#backstage-maintenance) for maintenance procedures.