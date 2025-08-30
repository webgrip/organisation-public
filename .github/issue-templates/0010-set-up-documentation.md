# In-Depth Project Documentation (auto-researched from official upstream)

**Objective**
Produce comprehensive, accurate, and maintainable documentation for this project by **deriving facts from the application’s official sources**. The project you need to look up is in the name of the repository. Look it up online. Get the links for all pertinent sources, including official documentation, GitHub repositories, and Docker image READMEs, public helm charts, etc. This will ensure that our documentation is grounded in the most reliable information available.

---

## Scope (what must be covered)

1. **Project Overview**

   * One-paragraph description of what the project is and which upstream application(s) it packages.

2. **Upstream Application Facts**

   * Application purpose and core features.
   * Supported versions and lifecycle policy (LTS/maintenance cadence if documented).
   * Official configuration approach (available environment variables, files, CLI, entrypoint behavior, a table for docker support, helm support, which values in `values.yaml` are configurable).
   * Supported databases, cache backends, mailers, and any optional components we enable here.

3. **Configuration**

   * Enumerate all required environment variables; explain purpose, default behavior, and constraints.
   * Document volume mounts and data persistence responsibilities (public assets, application storage, DB data, cache data, certificates).
   * Document all necessary services settings used by the application per upstream guidance.

4. **Compliance with Upstream**

    * Explicit statement that all behavior documented for the application is sourced from and consistent with official upstream docs.
    * Deviations (if any) and the reason they exist in this repository.

---

## Authoritative Sources (must consult and cite)

* Upstream application: official documentation site, official GitHub repository, official Docker image README (Docker Hub or GHCR), official release notes/changelog, and security advisories if pertinent.
* Reverse proxy/database/cache official image docs for runtime flags, init scripts, config paths, and healthcheck guidance.
* Cite each source with a **title, URL, and retrieval date**. Place citations at the end of the relevant section. Do not copy large verbatim passages; summarize in your own words and link.

---

## Output format & location

* Place documentation under `docs/` with the following minimum set:

  * `docs/adrs`: Architectural Decision Records
  * `docs/techdocs`: Custom mkdocs documentation, based on Spotify's techdocs. Think of a sensible way to structure this and use nav: in ./docs/techdocs/mkdocs.yml

* Each file must begin with a one-sentence purpose statement and a concise table of contents.
* Use consistent heading hierarchy, short paragraphs, and bullet lists for scanability.
* Use code fences for commands and config fragments; never include real secrets or tokens.

---

## Required content rules

* Facts must come from the official sources listed above; where multiple sources conflict, prefer the most recent official documentation and note any discrepancies.
* Do not invent configuration keys or file paths; only document what upstream supports and what this repo actually uses.
* Be explicit with ports, paths, and variable names; avoid ambiguous phrases like “it should work.”
* Make it reproducible: a newcomer should be able to read `./README.md`, run `make start`, and reach the application without guesswork.
* Mark any unknowns as **TODO** with a brief note about where to confirm, then resolve before closing the issue.

---

## Acceptance criteria (checklist)

* [ ] All `docs/*` files listed above are present, well-structured, and internally consistent.
* [ ] Documentation accurately describes this repo’s **image policy** (ops-built, org-owned, pinned upstream bases) and how Compose uses **only our images**.
* [ ] Makefile-driven quickstart works on a clean clone as written in `docs/README.md`.
* [ ] Environment variables, ports, volumes, and healthchecks match upstream documentation and this repository’s configuration.
* [ ] Upgrade and rollback procedures are documented and validated against our tagging policy.
* [ ] Troubleshooting section covers the most frequent operational issues in this stack.
* [ ] Every section that relies on upstream facts includes **source citations** (title, URL, retrieval date).
* [ ] No secrets or sensitive tokens are included anywhere in the docs.
* [ ] There are NO dead links or references. **ESPECIALLY** to upstream sources. Check everything.

---

## Definition of done

* The documentation set enables any engineer (new or existing) to understand **what we built**, **why we built it this way**, **how to operate it safely**, and **how to evolve it**—without leaving the repository.
* All guidance is aligned with **official upstream sources**, our **org image policy**, and the **Makefile/Compose** behavior in this project.
