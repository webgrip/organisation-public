# Create Helm charts (app + secrets) matching our org pattern

## Summary

Create two Helm charts:

1. **Main chart**: `<stack>-application` — deploys our org image(s) for the app, wiring ingress, service, resources, persistence, and (optional) Redis dependency.
2. **Secrets chart**: `<stack>-application-secrets` — holds Kubernetes secrets and **must be deployed first**.

The output must mirror the YAML shape shown below (anchors, sections, dependency layout), while enforcing our policies:

* Images **must** be our org images (built in `ops/`); tags are **pinned** (no `:latest`).
* Values must include `_shared_config` with `&hostname` and `&url` anchors, namespace, env, ingress, resources, persistence, and Redis settings.
* Charts must declare dependencies exactly as specified for the chosen stack (swap names/versions appropriately).

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
> Replace `<PINNED_TAG>` with an immutable, pinned tag (no `latest`).
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
    tag: "<PINNED_TAG>"      # pinned; do not use :latest
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
  # Primary app chart if you consume an upstream/operator-style chart:
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

## Constraints & rules

* **Pinned image tags only**; never use `:latest`.
* **Use our org images** (the images built from `ops/`), not upstream images.
* **Ingress** must set class `ingress-traefik` and the cert-manager issuer `letsencrypt-traefik`; TLS secret name follows `letsencrypt-<stack>`.
* **Namespace** is the stack name (e.g., `invoiceninja-application`).
* **Env** must include `TZ`, `INSTANCE_NAME`, and `BASE_URL`. Add only the keys explicitly supported by the app.
* **Persistence** uses `do-block-storage` by default; size defaults to `1Gi` unless the app requires more.
* **Redis** section is optional; include only if the application supports/uses it.
* **Secrets chart** must be installable independently and **before** the main chart; main chart must rely on `valueFrom.secretKeyRef` for sensitive values.
* All content must pass `helm lint` and a dry run (`helm install --dry-run --debug`).

---

## Acceptance criteria

* [ ] Charts and values follow the structure above (anchors, sections, and keys present).
* [ ] All images in values reference our org repo and **pinned** tags.
* [ ] Ingress/Service/Resources/Persistence fields are present and reasonably defaulted.
* [ ] Optional Redis section included only when required by the app and correctly wired.
* [ ] Secrets chart exists, deploys first, and keys are referenced from the main chart.
* [ ] `helm lint` passes for both charts; dry-run install succeeds with placeholder values.
* [ ] README updated with install order and sample `helm install` commands (secrets → app).
