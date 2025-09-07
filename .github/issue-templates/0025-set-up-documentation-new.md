# B) Docker Setup & Docs — Official-Image-First Policy

## Files to add/update

### `docs/techdocs/docs/operations/containerization-policy.md`

````markdown
---
title: "Containerization & Compose Policy"
description: "Org-owned images from pinned upstream bases; official app image preferred, source-build only if unsupported or unavailable."
tags:
  - operations
  - containerization
  - docker
  - compose
  - policy
search:
  boost: 4
  exclude: false
icon: material/steam
author: "<Infrastructure/Platform Team>"
date: 2025-01-09
---

# Containerization & Compose Policy (Org-Owned Images; Pinned Upstream)

> **Scope:** All local dev services—application, reverse proxy, database, cache, supplementary services.  
> **Out of scope:** Production deployments.

## Quickstart
```bash
cp .env.example .env
make start     # build & start the full stack
make logs      # tail logs
make enter     # shell into application
make stop      # teardown
````

## Core Policy (Authoritative)

1. **Own every image.** Each service has `ops/docker/<service>/Dockerfile` and builds to an **org-owned** image. Compose references **only our images**.
2. **Application image (strict order):**

   * **Preferred:** Use the **official upstream application image**, pinned:
     `FROM <official-app-image>:<exact-tag>` (+ optional digest).
   * **Fallback only if unavailable/unsupported:** Build **our** app image from **pinned upstream source** (tag/commit). Keep overlay minimal.
3. **Pinned bases.** Direct `FROM <official-upstream>:<exact-tag>`; no `ARG` indirection, no floating majors/minors, no `:latest` for bases. Prefer immutable tags/digests.
4. **Minimal overlay.** Only what’s strictly required (configs, init hooks). Multi-stage only when it clearly helps (size/artifacts).
5. **Compose uses our images only.** Each service references org images; `build` points to `ops/docker/<service>/Dockerfile`.
6. **Env → `.env.example`.** Mirror upstream docs for each image.
7. **Port hygiene.** Only the **reverse proxy** publishes host ports; apps **expose** internal ports.
8. **Configuration fidelity.** Volumes/env/health checks/entrypoints follow upstream docs for chosen bases.
9. **Reproducibility.** Clean clone + Makefile targets → working stack.
10. **Security & provenance.** PRs include chosen tags/digests, changelog links, and the app-image decision & rationale.

## Image Naming & Tagging

* **Naming:** `org/<stack>.<service>` (e.g., `orgname/<project>.application`, `.nginx`, `.mariadb`, `.redis`).
* **Tagging:** Immutable, human-traceable tags (project scheme). PR declares and uses one tag consistently across built images.
* Compose may use `${PROJECT_TAG:-dev}` for **our** images only (never for base `FROM`).

## Repository Layout

```
ops/
  docker/
    application/  (Dockerfile, app configs/init)
    nginx/        (Dockerfile, default.conf)
    mariadb/      (Dockerfile, my.cnf)
    redis/        (Dockerfile)
docs/
  techdocs/
    (this site)
docker-compose.yml
Makefile
.env.example
```

## Dockerfile Requirements

* **Direct pinned** base: `FROM <official-upstream>:<exact-tag>` (application uses official unless unsupported; otherwise build from source).
* Minimal overlay; upstream conventions and paths.
* No unrelated packages/runtimes.
* Multi-stage only when beneficial.
* Comment *what/why* for each overlay.

**Examples**

```dockerfile
# ops/docker/redis/Dockerfile
FROM redis:7.2.5@sha256:<digest>
# COPY redis.conf /usr/local/etc/redis/redis.conf  # only if required by upstream docs
```

```dockerfile
# ops/docker/application/Dockerfile (preferred official app image)
FROM <official-app-image>:<exact-tag>@sha256:<digest>
# Minimal overlay only if required
```

```dockerfile
# ops/docker/application/Dockerfile (fallback: build from upstream source)
FROM <official-build-base>:<exact-tag> AS build
# RUN git clone --depth 1 --branch <pinned-tag-or-commit> https://github.com/<upstream>/<app>.git /src
# RUN cd /src && <upstream build steps>

FROM <official-runtime-base>:<exact-tag>
# COPY --from=build /src/build/ /opt/app/
# EXPOSE 8080
# HEALTHCHECK --interval=10s --timeout=3s --retries=5 CMD curl -fsS http://localhost:8080/health || exit 1
```

## Compose Requirements

* Reference **only org images**; `build` points to `ops/docker/<service>/Dockerfile`.
* Only reverse proxy publishes host ports; apps use `expose`.
* Health checks defined where supported; volumes for persistent data.
* Consistent network usage.

```yaml
version: "3.9"

services:
  nginx:
    image: orgname/<project>.nginx:${PROJECT_TAG:-dev}
    build:
      context: .
      dockerfile: ops/docker/nginx/Dockerfile
    ports: ["8080:80"]
    depends_on:
      application:
        condition: service_healthy

  application:
    image: orgname/<project>.application:${PROJECT_TAG:-dev}
    build:
      context: .
        # dockerfile path must remain in sync with ops/docker/application/Dockerfile
      dockerfile: ops/docker/application/Dockerfile
    env_file: .env
    expose: ["8080"]
    healthcheck:
      test: ["CMD-SHELL", "curl -fsS http://localhost:8080/health || exit 1"]
      interval: 10s
      timeout: 3s
      retries: 10

  mariadb:
    image: orgname/<project>.mariadb:${PROJECT_TAG:-dev}
    build:
      context: .
      dockerfile: ops/docker/mariadb/Dockerfile
    environment:
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
    volumes:
      - mariadb-data:/var/lib/mysql
    healthcheck:
      test: ["CMD-SHELL", "mysqladmin ping -h localhost -p${MYSQL_ROOT_PASSWORD} --silent"]
      interval: 10s
      timeout: 5s
      retries: 10

  redis:
    image: orgname/<project>.redis:${PROJECT_TAG:-dev}
    build:
      context: .
      dockerfile: ops/docker/redis/Dockerfile
    expose: ["6379"]
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 10

volumes:
  mariadb-data:
```

## Makefile (Canonical)

```makefile
PROJECT_TAG ?= dev

start:
\tdocker compose up -d --build

stop:
\tdocker compose down -v --remove-orphans

logs:
\tdocker compose logs -f --tail=200

enter:
\tdocker compose exec application sh

run:
\tdocker compose exec application $(CMD)
```

## `.env.example`

```env
# Application
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8080

# Database
MYSQL_DATABASE=app
MYSQL_USER=app
MYSQL_PASSWORD=app
MYSQL_ROOT_PASSWORD=root

# Redis
REDIS_HOST=redis
REDIS_PORT=6379
```

## PR Requirements (Docker)

* List upstream base images and **exact tags/digests** for each service.
* For **application**: state **official image** vs **fallback source build**; provide justification and **pinned tag/commit**.
* Link upstream release notes/changelogs for pin changes.
* Keep TechDocs pages updated.

## Validation (Must Pass)

* Clean clone → `make start` → working stack (no manual steps).
* Reverse proxy serves the app; internal ports not host-mapped.
* Health checks turn **healthy** for all services.
* `make stop` leaves no orphans.

## Acceptance Checklist

* [ ] Dockerfiles exist for **all** services with **direct pinned** `FROM` (no `ARG`).
* [ ] **Application** uses official image when supported; otherwise fallback source build is **pinned** & justified.
* [ ] Compose references **only** org images; names match Makefile.
* [ ] Ports/health/volumes/env align with upstream docs.
* [ ] Make targets (`start`, `stop`, `logs`, `enter`, `run`) work end-to-end.
* [ ] TechDocs updated with tags/digests and rationale.
