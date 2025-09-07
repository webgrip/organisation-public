Perfect — your `mkdocs.yml` looks solid for Material + TechDocs. I wouldn’t change it unless you want niceties like `repo_url`/`edit_uri` (handy “Edit this page” links) or to drop either `markdown_inline_mermaid` **or** `mermaid2` if you ever notice duplicate Mermaid rendering (they can coexist, but one is enough).

Below are the two **separate bundles** you asked for, tailored to your existing config. Just add these files and extend your `nav:`.

---

# A) Project Documentation (Copilot-driven, iterative)

### `docs/techdocs/docs/playbooks/copilot-repo-cartography.md`

```markdown
---
title: "Copilot Playbook: Build a Complete Repo Map"
description: "Repeatable workflow to generate and maintain a TechDocs site from the repository."
tags: [playbook, documentation, techdocs, mkdocs, copilot]
search:
  boost: 4
  exclude: false
icon: material/robot
author: "WebGrip Documentation"
date: 2025-09-03
---

# Copilot: End-to-End Understanding of This Repository

## Summary
Use GitHub Copilot to produce a **complete, accurate, navigable** overview of this repo. This playbook is **observational + synthesizing** (no refactors), with guardrails to avoid secrets and to cite sources.

## Guardrails
- **No secrets**: never include values from `.env`, vaults, or CI secrets.
- **Stay in repo**: use only committed code/config/docs.
- **Cite sources**: relative file links (add line ranges when helpful).
- **Mark uncertainty**: use `> Assumption:` with a validation step.
- **Reproducible**: anyone can re-run these prompts.

## Deliverables
1. **IA alternatives** (2–3) mapped to code seams/ownership.
2. **Approved `nav:`** for `mkdocs.yml`.
3. **Content pages** (small, link-rich, diagrams as text).
4. **Cross-links & citations** to code/config.
5. **ADRs surfaced** (`docs/adrs/` link or rendered).
6. **Buildable TechDocs** locally & in Backstage.

## Phase 0 — Kickoff & Index
**Prompt A — Kickoff**
```

You are a repository cartographer. Stay within the repo; do not reveal secrets; cite files; mark assumptions.
Deliver Markdown under docs/techdocs/docs/. Confirm understanding and list top-level folders and key entry points.

```

**Prompt B — Inventory**
```

List: top-level folders; languages/frameworks; build files; CI workflows; tests; configuration; Docker/K8s/Terraform; migrations; Helm; docs. Return repo-relative links.

```

## Phase 1 — IA Alternatives
```

Propose 2–3 TechDocs information architectures using repo-specific seams (domains, layers, runtime, interfaces, data, operations, ownership).
Give rationale, map sections to directories/files, and recommend one. Keep depth ≤ 3.

```

## Phase 2 — Generate Navigation
```

Turn the approved IA into a mkdocs `nav:` block. Choose concise names and paths. Show the nav and explain mapping to repo locations.

```

## Phase 3 — Create Content (Seam-by-Seam)
```

For <chosen seam>, create pages per the IA. Include: purpose & audience, link-rich explanations to code/config, Mermaid/ASCII diagrams,
`> Assumption:` blocks where inferred, and cross-links. Return a file list + short summaries.

```

## Phase 4 — ADR Integration
```

Detect ADRs in docs/adrs/. Propose surfacing (link out vs. render). Implement and add contributor guidance.

```

## Phase 5 — Quality & Consistency
- **Link audit** (fix broken/missing)
- **Terminology** (normalize names)
- **Assumptions** (`> Assumption:` + validation)
- **Diagrams** (render check; focus views)

## Phase 6 — Publish & Hand-off
```

Create "Maintaining TechDocs": how IA maps to repo; how to add pages; when to add/update ADRs; add a PR checklist item.

```

## Acceptance Criteria
- ≥2 IA options; one selected with repo-tied rationale
- `plugins: [techdocs-core]` present; approved `nav:` added
- TechDocs builds; diagrams render
- Pages small, link-rich; claims cite code/config
- Assumptions visible + validation steps
- ADRs discoverable + contributor guidance
- Maintenance page exists
```

### `docs/techdocs/docs/playbooks/copilot-daily-refresh.md`

```markdown
---
title: "Daily Docs Refresh (Iterative Template)"
description: "A repeatable, small daily routine to keep TechDocs fresh."
tags: [playbook, maintenance, cadence, automation]
search:
  boost: 4
  exclude: false
icon: material/calendar-sync
author: "WebGrip Documentation"
date: 2025-09-03
---

# Daily Docs Refresh (15–30 min)

## Checklist
1. Pull latest; build & test.
2. Re-run **Inventory** on changed paths (git diff).
3. Update affected pages; add/adjust cross-links.
4. Add `> Assumption:` where inference occurs; propose validation.
5. Run link & diagram audits.
6. Commit with **Docs Changelog**.

## Prompts

**Diff-Scoped Inventory**
```

List files changed since <commit>. For each, state which TechDocs page(s) are affected and why. Return repo-relative links.

```

**Page Update Generator**
```

Given changes in <paths>, propose edits to \<page.md>. Keep pages small and link-rich, cite files/lines where helpful, and mark inferences as `> Assumption:` with validation.

```

**Cross-Link Pass**
```

Scan updated pages and suggest cross-links to related pages. Insert where relevant.

```

**Link & Diagram Audit**
```

Check for broken/missing links and non-rendering Mermaid/ASCII diagrams. Return fixes and patches.

```

## Docs Changelog
```

### Docs (YYYY-MM-DD)

* Updated: \<page(s)>
* Added: \<page(s)>
* Removed: \<page(s)>
* Notes: \<assumptions + planned validations>

```
```

### `docs/techdocs/docs/playbooks/maintaining-techdocs.md`

```markdown
---
title: "Maintaining TechDocs"
description: "How to extend the IA, when to add pages, and how to keep docs current."
tags: [playbook, maintenance]
search:
  boost: 3
  exclude: false
icon: material/playlist-check
author: "WebGrip Documentation"
date: 2025-09-03
---

# Maintaining TechDocs

- **IA extensions:** follow existing seams; keep nav depth ≤ 3.
- **Small pages:** prefer link-rich, focused pages over mega-pages.
- **ADRs:** add one for any decision with lasting impact; link from related pages.
- **PR template:** include “Updated overview docs?” checkbox.

> Assumption: PR template includes a docs checkbox.  
> Validation: verify `.github/pull_request_template.md`.
```

### `docs/techdocs/docs/adrs/index.md`

```markdown
---
title: "Architectural Decision Records"
description: "Where ADRs live and how to work with them."
tags: [adrs, architecture]
search:
  boost: 3
  exclude: false
icon: material/file-document
author: "WebGrip Architecture"
date: 2025-09-03
---

# ADRs

ADRs live at `docs/adrs/` (e.g., MADR). Link new ADRs from relevant pages.

> Assumption: ADRs exist at `docs/adrs/`.  
> Validation: verify directory and add CI check if missing.
```

---

# B) Docker Setup & Docs (official-image-first + Compose/Makefile)

### `docs/techdocs/docs/operations/index.md`

```markdown
---
title: "Operations"
description: "Day-to-day operational procedures for managing the application and its supporting services."
tags:
  - operations
  - monitoring
  - maintenance
  - backup
  - performance
search:
  boost: 4
  exclude: false
icon: material/monitor-dashboard
author: "WebGrip Infrastructure Team"
date: 2025-09-03
---

# Operations

This section covers runbooks, observability, CI/CD & environments, and the **Containerization & Compose Policy**.
```

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
author: "WebGrip Infrastructure Team"
date: 2025-09-03
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

* **Naming:** `org/<stack>.<service>` (e.g., `webgrip/<project>.application`, `.nginx`, `.mariadb`, `.redis`).
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
# COPY redis.conf /usr/local/etc/redis/redis.conf  # only if required
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
    image: webgrip/<project>.nginx:${PROJECT_TAG:-dev}
    build:
      context: .
      dockerfile: ops/docker/nginx/Dockerfile
    ports: ["8080:80"]
    depends_on:
      application:
        condition: service_healthy

  application:
    image: webgrip/<project>.application:${PROJECT_TAG:-dev}
    build:
      context: .
      dockerfile: ops/docker/application/Dockerfile
    env_file: .env
    expose: ["8080"]
    healthcheck:
      test: ["CMD-SHELL", "curl -fsS http://localhost:8080/health || exit 1"]
      interval: 10s
      timeout: 3s
      retries: 10

  mariadb:
    image: webgrip/<project>.mariadb:${PROJECT_TAG:-dev}
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
    image: webgrip/<project>.redis:${PROJECT_TAG:-dev}
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
* Keep TechDocs updated.

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

````

---

## Minimal `nav:` patch for your existing `mkdocs.yml`

Add these under `nav:` (keeping your `Home: index.md`):

```yaml
nav:
  - Home: index.md
  - Playbooks:
      - Copilot Repo Cartography: playbooks/copilot-repo-cartography.md
      - Daily Docs Refresh: playbooks/copilot-daily-refresh.md
      - Maintaining TechDocs: playbooks/maintaining-techdocs.md
  - Operations:
      - Operations Index: operations/index.md
      - Containerization & Compose Policy: operations/containerization-policy.md
  - ADRs:
      - About ADRs: adrs/index.md
      - Records (directory): ../adrs/
````
