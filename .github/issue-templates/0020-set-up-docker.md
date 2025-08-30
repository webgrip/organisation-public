# Set up project Dockerfiles from official upstream tags, and docker-compose.yml

## Summary

Adopt a **self-maintained image policy** for this project. For **every dependency and service**, maintain a Dockerfile under `ops/docker/<service>/Dockerfile` that **directly** `FROM`s the **official upstream image** using a **pinned, immutable tag**. Build from those Dockerfiles and **use only our images** in `docker-compose.yml`. The provided **Makefile** is the canonical interface for local lifecycle commands.

---

## Scope

* Applies to all project services: application, database, cache, supplementary services, and any additional service introduced later.
* Covers Dockerfiles, image naming and tagging, Compose configuration, and developer workflow.
* Does not cover deployments.

---

## Policy (authoritative)

1. **Own every image.** Each service has an org-owned image built from `ops/docker/<service>/Dockerfile`.
2. **Upstream as base.** Each Dockerfile **must** begin with a **direct** `FROM <official-upstream>:<exact-tag>`.

   * No `:latest`, **except** for the tags we assign the built images in `docker-compose.yml`.
   * No floating majors/minors.
   * Always use the latest minor version. Always check for updates before building.
   * No `ARG` indirection for base selection.
   * Prefer immutable tags; optionally include a digest if available and appropriate.
3. **Minimal overlay.** Dockerfiles add only what is strictly required by this project (configuration, init hooks, site files). Avoid base OS swaps, build toolchains, or unrelated utilities. Use multi-stage **only** when necessary. Do not add configuration unless the upstream image requires it, or you deem it necessary.
4. **Compose uses our images only.** `docker-compose.yml` must reference the org-owned images (not upstream) for all services.
5. **Add environment variables** to `.env.example` as needed for each service according to the upstream documentation.
6. **Port hygiene.** Internal application process ports remain internal to the Compose network. Only the reverse proxy publishes host ports.
7. **Configuration fidelity.** Environment variables, volume mounts, health checks, and entrypoint behavior must match the upstream documentation of the chosen base image. Values are provided via the project’s env file and Compose.
8. **Reproducibility.** A clean clone plus the Makefile targets must build, start, and operate the stack without manual steps.
9. **Security & provenance.** Keep upstream base pins explicit; document chosen upstream tag(s) and changelog links in the PR. Avoid unverified third-party layers.

---

## Image naming (required)

* Organization registry namespace is authoritative.
* Image names follow the **stack.service** pattern under the org namespace. Take this as an example of one of the services:

  * `webgrip/invoiceninja-application.application`
  * `webgrip/invoiceninja-application.nginx`
  * `webgrip/invoiceninja-application.mariadb`
  * `webgrip/invoiceninja-application.redis`
  * `webgrip/invoiceninja-application.mkcert`
* Additional services must follow the same naming convention.

---

## Tagging (required)

* Tags are immutable and human-traceable.
* Use a project-standard tag scheme.
* The tag chosen for a PR must be declared in the PR description and applied consistently across images built in that PR.

---

## Repository layout (required)

* One Dockerfile per service in `ops/docker/<service>/Dockerfile`.
* Service-specific configuration resides alongside each Dockerfile (for example, site configs, init scripts, or service configs).
* The root `docker-compose.yml` is the single source of truth for local development; no parallel dev compose files.

---

## Dockerfile requirements (mandatory)

* Begins with a **direct** `FROM` to the official upstream image with an **exact** tag.
* Contains **only** minimal additions needed for this project.
* Uses standard upstream-documented paths and conventions for configuration, init hooks, and runtime.
* Does **not** introduce unrelated packages, shells, or language runtimes beyond what the base image prescribes.
* Uses multi-stage builds only when there is a clear benefit (e.g., reducing final image size or producing build artifacts that are not needed at runtime).
* Maintains clear comments explaining any overlay added and the reason it is required.

---

## Compose requirements (mandatory)

* All services reference **our** images using the org registry and required naming scheme.
* Build contexts in Compose point to the corresponding `ops/docker/<service>/Dockerfile`.
* Only the reverse proxy publishes host ports. Application internal ports are **exposed** to the Compose network, not host-mapped.
* Health checks are defined where supported to ensure dependency ordering and readiness.
* Volumes are declared for persistent data where required.
* The default network is used unless a project network is already defined; network usage must remain consistent across services.

---

## Makefile integration (mandatory)

* The provided Makefile is the **canonical** developer interface for local lifecycle.
* Targets must function on a clean clone with Docker and Compose installed:

  * `start` brings up the full stack in the background.
  * `stop` tears it down.
  * `logs` streams logs (all services or a selected service).
  * `enter` attaches an interactive shell to the application service.
  * `run` executes one-off commands in the application service.
  * Additional documented targets remain operative as described in the Makefile.
* Compose and service names used in the Makefile must remain in sync with `docker-compose.yml`.

---

## Documentation (mandatory)

* The PR description lists the upstream bases and **exact** tags used for each service.
* The documentation in ./docs is up-to-date and reflects the current state of the project. Keep to the architecture that is in there.
* No untracked “tribal knowledge”; all operational requirements live in the repository.

---

## Validation (must pass)

* Clean environment → repository checkout → `make start` results in a working stack without manual intervention.
* Reverse proxy serves the application over the published port(s).
* The application can reach its dependencies and initialize as expected.
* Health checks report healthy across services.
* `make stop` shuts down cleanly with no orphaned resources.

---

## Risks & mitigations

* **Upstream breaking changes:** mitigated by pinned tags and explicit testing before updating pins.
* **Supply-chain disruption:** mitigated by building and hosting org images; the registry contains the deployable artifacts.
* **Configuration drift:** mitigated by keeping overlays minimal and aligned with upstream documentation.
* **Local reproducibility issues:** mitigated by Makefile targets and strict Compose conventions.

---

## Acceptance criteria (checklist)

* [ ] Dockerfiles exist for **all** services under `ops/docker/<service>/Dockerfile`, each `FROM` the official upstream image with a pinned exact tag and no `ARG`.
* [ ] `docker-compose.yml` references only the org images and aligns with the Makefile service names.
* [ ] Internal application ports are not host-mapped; only the reverse proxy publishes host ports.
* [ ] Health checks, volumes, and environment configuration align with upstream documentation.
* [ ] The Makefile commands operate end-to-end on a clean clone.
* [ ] README and PR description contain the required documentation and tag disclosures.
* [ ] Documentation in ./docs and README.md is up-to-date and reflects the current state of the project.

---

## Definition of done

The repository contains a complete, reproducible, and documented containerization setup in which **every** service runs from **org-owned images** built from **pinned upstream bases**, the **Makefile** is the single entry point for local operations, **Compose** references only our images.
