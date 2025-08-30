# Create Helm charts (app + secrets) matching our org pattern

## Summary

Create two Helm charts:

1. **Main chart**: `<stack>-application` — deploys our org image(s) for the app, wiring ingress, service, resources, persistence, and (optional) Redis dependency.
2. **Secrets chart**: `<stack>-application-secrets` — holds Kubernetes secrets and **must be deployed first**.

The output must mirror the YAML shape shown below (anchors, sections, dependency layout), while enforcing our policies:

* Images **must** be our org images (built in `ops/`); tags are **pinned** (no `:latest`) **everywhere except the Helm value for the deployed image**, which may be `latest` per our rollout convention.
* Values must include `_shared_config` with `&hostname` and `&url` anchors, namespace, env, ingress, resources, persistence, and Redis settings.
* Charts must declare dependencies **only** on official or active community-maintained charts (never the bwj app template).
* **Research online** to locate the official/community chart for the chosen app; record the repository URL and version in the PR.

---

## Deliverables

* `ops/helm/<stack>-application/Chart.yaml`
* `ops/helm/<stack>-application/values.yaml`
* `ops/secrets/<stack>-application-secrets/Chart.yaml`
* `ops/secrets/<stack>-application-secrets/values.yaml`

Each file must validate with `helm lint`.

---

## Required structure (fill in placeholders)

> Replace `<stack>` with the stack name (e.g., `invoiceninja-application`, `firefly-application`, `searxng-application`).
> Replace `<org-repo>` with your org image (e.g., `webgrip/<stack>`).
> Replace dependency names/versions/repositories with the correct ones for the chosen app.

### `ops/helm/<stack>-application/values.yaml`

```yaml
namespace: <stack>

_shared_config:
  hostname: &hostname <hostname.fqdn>
  url: &url https://<hostname.fqdn>

<app-key>:
  image:
    repository: <org-repo>
    tag: "latest"
    pullPolicy: Always
  global:
    fallbackDefaults:
      pvcSize: 1Gi
      storageClass: do-block-storage

  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 250m
      memory: 256Mi

  service:
    main:
      ports:
        main:
          enabled: true
          port: 8080
          protocol: http

  ingress:
    main:
      enabled: true
      ingressClassName: ingress-traefik
      annotations:
        cert-manager.io/cluster-issuer: letsencrypt-traefik
        # traefik.ingress.kubernetes.io/router.middlewares: "<optional-middleware-refs>"
      hosts:
        - host: *hostname
          paths:
            - path: /
              pathType: Prefix
              service:
                name: <stack>
                port: 8080
      tls:
        - secretName: letsencrypt-<stack>
          hosts:
            - *hostname

  persistence:
    config:
      enabled: true
      size: 1Gi
      storageClass: do-block-storage

  env:
    TZ: Europe/Amsterdam
    INSTANCE_NAME: <stack>
    BASE_URL: *url

    # Add app-specific variables here (exact keys required by the app).
    # All sensitive values must be referenced from the secrets chart:
    SOME_APP_SECRET:
      valueFrom:
        secretKeyRef:
          name: <stack>-secrets
          key: some-app-secret
```

> Notes:
>
> * `<app-key>` must match the subchart or top-level key consumed by the dependency (e.g., `searxng`, `firefly`, `invoiceninja`).
> * If your app needs Redis, add the env key pointing to the in-cluster Redis service FQDN.

### Optional Redis (include only if needed)

```yaml
redis:
  architecture: replication
  auth:
    enabled: false
  master:
    persistence:
      enabled: true
      size: 1Gi
  replica:
    replicaCount: 0
```

### `ops/helm/<stack>-application/Chart.yaml`

```yaml
apiVersion: v2
name: <stack>
description: "Helm Chart for deploying <stack> on Kubernetes."
type: application
version: 0.2.0
appVersion: "<APP_VERSION_PINNED>"

dependencies:
  # Primary app chart if you consume an official/community-maintained chart:
  - name: <app-key>
    version: <APP_CHART_VERSION_PINNED>
    repository: <OCI_OR_HELM_REPOSITORY_URL>
  # Our shared helpers:
  - name: common-helpers
    repository: oci://ghcr.io/webgrip/common-charts
    version: 1.0.13
  # Optional auxiliary services such as redis or postgres (remove if not required):
  - name: redis
    version: <REDIS_CHART_VERSION_PINNED>
    repository: oci://registry-1.docker.io/bitnamicharts
```

---

## Secrets chart (deployed first)

### `ops/secrets/<stack>-application-secrets/Chart.yaml`

```yaml
apiVersion: v2
name: <stack>-secrets
description: "Helm chart to store secrets for <stack>."
type: application
version: 0.1.0
```

### `ops/secrets/<stack>-application-secrets/values.yaml`

```yaml
namespace: <stack>

# List each secret as key: value (or wire SOPS separately).
# Do not commit real secrets. Use CI to inject or use SOPS/age in a private path.
some-app-secret: "<PLACEHOLDER_OR_ENCRYPTED_VALUE>"
```

> This chart creates a Secret named `<stack>-secrets` in the `<stack>` namespace (or as defined in your templates), and the main chart must reference keys via `valueFrom.secretKeyRef`.

---

## Research & selection rules (must follow)

* **Locate official or active community-maintained charts** for the chosen app (never the bwj app template).
* Validate “active” by checking **recent commits/releases** and open issues/PRs. Prefer OCI registries with signed artifacts when available.
* Record in the PR description for each dependency: **chart name**, **version**, **repository URL**, and **why it qualifies** (official or active community-maintained).
* Pin **chart versions** in `Chart.yaml` and **our app image tags** in your `ops/` Dockerfiles (no floating tags).
* Use our org images in values (repository `<org-repo>`). Our Dockerfiles in `ops/` must `FROM` pinned upstream images.

---

## Constraints & rules

* **Pinned image tags everywhere** in `ops/` builds and CI; **the only exception** is the Helm value `image.tag: "latest"` for the deployed app image, which maps to our org’s “current” tag policy.
* **Do not** depend on bwj app template. Use **official** or **active community** charts only.
* **Ingress**: class `ingress-traefik`, issuer `letsencrypt-traefik`; TLS secret `letsencrypt-<stack>`.
* **Namespace** equals `<stack>`.
* **Env**: must include `TZ`, `INSTANCE_NAME`, `BASE_URL`; add only keys recognized by the app.
* **Persistence**: default `do-block-storage`, `1Gi` unless the app requires more.
* **Redis**: include section only if used by the app and wire env accordingly.
* Everything must pass `helm lint` and `helm install --dry-run --debug`.

---

## Acceptance criteria

* [ ] Charts and values exactly follow the structure above (anchors, sections, keys).
* [ ] Dependencies point to **official or active community-maintained** charts, with repo URLs and pinned versions captured in the PR.
* [ ] Image repository points to our org; `image.tag` in values is `"latest"` per policy, but our `ops/` images and CI are strictly pinned.
* [ ] Ingress/Service/Resources/Persistence are present and sane; Redis included only when required.
* [ ] Secrets chart deploys first; main chart references secrets via `valueFrom.secretKeyRef`.
* [ ] `helm lint` passes for both charts; dry-run install succeeds with placeholders.

---

**Notes for the PR:** include links to the chosen charts’ repositories/OCI indexes, the pinned versions, and a one-liner on their activity (last release/commit).
