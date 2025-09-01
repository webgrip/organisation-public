# Generate Helm charts (app + secrets) that follow our pattern — with **complete** `values.yaml` ready to fill

## Goal

Create two Helm charts that conform to our house style and can be deployed immediately after filling a few required fields:

1. **Main chart**: `ops/helm/<stack>-application`
2. **Secrets chart**: `ops/secrets/<stack>-application-secrets` (installed **first**)

This task **must**:

* Use an **official or actively maintained community chart** as a dependency (found on Artifact Hub) — never the bwj app template.
* Generate a **complete** `values.yaml` for our main chart that lists **every configurable value the dependency exposes**—pre-filled with upstream defaults where they exist, and **clearly marked** placeholders (`# REQUIRED`) where the user must supply a value.
* Keep our existing organization image policy: the org-owned image (built from `ops/`) is referenced in `values.yaml`; CI/ops pin image tags, while in Helm **`image.tag: "latest"`** is permitted to represent “current org release”.

---

## What you will deliver

* `ops/helm/<stack>-application/Chart.yaml`
* `ops/helm/<stack>-application/values.yaml` (or `values.yml`)
* `ops/secrets/<stack>-application-secrets/Chart.yaml`
* `ops/secrets/<stack>-application-secrets/values.yaml` (or `values.yml`)

All files must pass `helm lint` and a dry run (`helm install --dry-run --debug`).

---

## How to gather the source of truth (no guessing)

1. **Find the chart** on Artifact Hub (e.g., Invoice Ninja: `invoiceninja/invoiceninja`). Record the **repository URL** and a **pinned version**.
2. **Pull the real defaults** for that version:

   ```
   helm repo add <name> <url>
   helm repo update
   helm show values <name>/<chart> --version <X.Y.Z> > /tmp/upstream-values.yaml
   ```
3. **Use `/tmp/upstream-values.yaml` as the contract**. Every key you override or surface must **match the dependency’s schema and nesting**. Do not rename keys. Do not invent new ones.

---

## Rules for the main chart (`ops/helm/<stack>-application`)

### `Chart.yaml`

* `apiVersion: v2`, `type: application`.
* `name: <stack>` (e.g., `searxng-application`, `invoiceninja-application`).
* `version`: start at `0.1.0` (our chart version).
* `appVersion`: set to the **application** version string you are targeting.
* `dependencies`:

  * The **upstream app chart** you found (pinned version, OCI/HTTP repo URL).
  * `common-helpers` from `oci://ghcr.io/webgrip/common-charts` (pinned).
  * Optional extras (e.g., Bitnami `redis`) only if the app uses them (pinned).

### `values.yaml` (must be **complete**)

* Top-level standard fields we require:

  * `namespace: <stack>`
  * `_shared_config.hostname: &hostname <FQDN>` and `_shared_config.url: &url https://<FQDN>` (YAML anchors)
* A single top-level section named exactly after the dependency’s root key (e.g., `invoiceninja`, `searxng`, `firefly`). **All overridden/important values must live under this key**.
* **Image settings** under that key, using our org image:

  * `image.repository: <org-repo>` (e.g., `webgrip/<stack>`)
  * `image.tag: "latest"` (Helm values only — CI/ops remain pinned)
  * `image.pullPolicy: Always`
* **Resources**: provide sane defaults (`requests`/`limits`), editable by users.
* **Service & ports**: copy the exact keys and defaults from upstream (`containerPorts.*`, `service.port`, probe ports).
* **Ingress**: our standard ingress block using Traefik + cert-manager; hosts use `*hostname` and TLS secret `letsencrypt-<stack>`.
* **Persistence**: keep the upstream structure and names; set our defaults (e.g., `storageClass: do-block-storage`, sizes).
* **Environment/config**: include the upstream’s documented config knobs (names as-is).
* **Redis block**: include **only if the upstream chart supports/uses it**; otherwise omit or ensure `enabled: false`.

#### Very important: include **placeholders** for anything not auto-filled

* For every upstream key that has **no default** or requires a site-specific value (secrets, credentials, URLs, mail settings, etc.), put a placeholder and a clear comment:

  ```
  someCriticalKey: ""   # REQUIRED: set this to <describe expectation>
  ```
* For every secret value, do **not** put plaintext. Instead, wire it like:

  ```
  someSecret:
    valueFrom:
      secretKeyRef:
        name: <stack>-secrets
        key: someSecret
  ```
* **Do not omit** any important knobs from the upstream chart simply because we are not changing them. If a value is likely to be changed by operators (env, ports, persistence, replicas, probes, mail, cache/session/queue drivers, etc.), surface it with the upstream default and a brief comment.

---

## Secrets chart (`ops/secrets/<stack>-application-secrets`) — install **first**

### `Chart.yaml`

* Minimal app chart descriptor. Use `version: 0.1.0`.

### `values.yaml`

* `namespace: <stack>`
* A list of key/value pairs for secrets used by the main chart.
* Put **placeholders** or use your SOPS workflow — never commit real secrets.
* The main chart must reference these via `valueFrom.secretKeyRef`.

---

## Image & tagging policy (don’t drift)

* The **org image** referenced in the main chart’s `values.yaml` is the image we build from `ops/` Dockerfiles.
* CI and Dockerfiles must use **pinned** upstream bases and pinned org tags.
* In **Helm values only**, `image.tag: "latest"` is allowed to represent “current org release”.

---

## Structure you must produce (shape only; fill with real keys from upstream)

```yaml
namespace: <stack>

_shared_config:
  hostname: &hostname <FQDN>     # REQUIRED: set your DNS name
  url: &url https://<FQDN>       # REQUIRED: keep protocol + host

<app-key>:                       # exact root key from upstream chart
  image:
    repository: <org-repo>       # REQUIRED: org image (ours), not upstream
    tag: "latest"                # Helm value only; CI/ops use pinned tags
    pullPolicy: Always

  # Copy these sections and key names from upstream values.yaml, not from memory:
  resources:
    requests:
      cpu: 250m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi

  service:
    # mirror upstream structure and defaults (ports, names, types)
    # REQUIRED: ensure the port here matches what ingress targets
    # ...

  ingress:
    main:
      enabled: true
      ingressClassName: ingress-traefik
      annotations:
        cert-manager.io/cluster-issuer: letsencrypt-traefik
      hosts:
        - host: *hostname
          paths:
            - path: /
              pathType: Prefix
              service:
                name: <stack>
                port: <UPSTREAM_SERVICE_PORT>  # REQUIRED: match upstream
      tls:
        - secretName: letsencrypt-<stack>
          hosts:
            - *hostname

  persistence:
    # keep upstream structure (e.g., public/storage sections)
    # provide our defaults for class/size
    # ...

  env:
    TZ: Europe/Amsterdam
    INSTANCE_NAME: <stack>
    BASE_URL: *url
    # Include all important upstream-config keys the operator may change.
    # REQUIRED: mark items the user must fill in:
    # someCriticalKey: ""  # REQUIRED: describe what to put here
    # someSecret:
    #   valueFrom:
    #     secretKeyRef:
    #       name: <stack>-secrets
    #       key: someSecret

# Include only if the upstream chart supports it and we enable it:
redis:
  # mirror upstream defaults and structure or set enabled: false
  # ...
```

---

## Clear instructions for the user (to avoid surprises)

* Open `ops/helm/<stack>-application/values.yaml`.
* Search for **`# REQUIRED`** and fill in the placeholders (FQDN, secrets, emails, passwords, mailer settings, etc.).
* If your application needs Redis (or any optional dependency), set `enabled: true` in the corresponding section and verify the service/port keys match the upstream chart.
* Install order:

  1. `helm upgrade --install <stack>-secrets ops/secrets/<stack>-application-secrets -n <stack> --create-namespace`
  2. `helm upgrade --install <stack> ops/helm/<stack>-application -n <stack>`

---

## Acceptance checklist

* [ ] Dependency is the **official or active community chart** (pinned version, repo URL recorded).
* [ ] `values.yaml` is **complete**: all relevant upstream keys are present with defaults or `# REQUIRED` placeholders. No invented keys.
* [ ] Our image repository is set (org image), `image.tag` is `"latest"` **only in Helm values**, and comments clarify that CI/ops use pinned tags.
* [ ] Ingress/Service/Ports match the upstream chart’s ports; TLS and class follow our standard.
* [ ] Persistence and (if used) Redis blocks mirror the upstream chart’s structure and include our defaults.
* [ ] Secrets chart exists, is installed first, and all sensitive values in the main chart reference it via `secretKeyRef`.
* [ ] `helm lint` and `helm install --dry-run --debug` both pass.

---

## PR notes

Attach:

* The Artifact Hub link for the chosen chart.
* `helm show values …` output for the pinned version (as an artifact or gist) to prove key names.
* A short list of **`# REQUIRED`** fields the operator must fill before install.
