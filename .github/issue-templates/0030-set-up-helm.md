Here you go — a complete, paste-ready GitHub issue you can use for **<stack>-application**. It includes your config, deliverables, commands, acceptance checklist, and PR notes.

---

# Generate Helm charts (app + secrets) with a **complete** values.yaml — <stack>-application

## Goal

Create two Helm charts that follow our house style and can be deployed immediately after filling a few required fields:

1. **Main chart:** `ops/helm/<stack>-application`
2. **Secrets chart:** `ops/secrets/<stack>-application-secrets` (install **first**)

### High-level requirements

* Use an **official or actively maintained community chart** from Artifact Hub as the dependency whenever possible.

  * If no proper upstream app chart exists, or it has not been maintained, **use `bjw-s/app-template`** (pinned version).
* Produce a **complete** `values.yaml` for the main chart that surfaces **every configurable value the dependency exposes**—pre-filled with upstream defaults where they exist, and **clearly marked** placeholders (`# REQUIRED`) where the operator must provide a value.
* Keep our image policy:

  * Reference the **org image** (built from `ops/`) in `values.yaml`.
  * CI/ops pin image tags; in Helm values, `image.tag: "latest"` is allowed and means “current org release”.

---

## Deliverables

* `ops/helm/<stack>-application/Chart.yaml`
* `ops/helm/<stack>-application/values.yaml` (or `values.yml`)
* `ops/secrets/<stack>-application-secrets/Chart.yaml`
* `ops/secrets/<stack>-application-secrets/values.yaml` (or `values.yml`)

All files must pass:

```bash
helm lint ops/helm/<stack>-application
helm lint ops/secrets/<stack>-application-secrets

helm upgrade --install <stack>-application-secrets ops/secrets/<stack>-application-secrets -n <stack>-application --create-namespace --dry-run --debug
helm upgrade --install <stack>-application        ops/helm/<stack>-application          -n <stack>-application --dry-run --debug
```

---

## Source of truth (no guessing)

1. **Pick dependency on Artifact Hub**. Record the **repository URL** and a **pinned version**.

   * For this issue: use **`bjw-s/app-template`** (pinned), plus optional Bitnami `redis` and `mariadb`.
2. **Pull the exact defaults for that pinned version:**

   ```bash
   helm repo add bjw-s oci://ghcr.io/bjw-s/helm
   helm repo add bitnami oci://registry-1.docker.io/bitnamicharts
   helm repo update
   helm show values bjw-s/app-template --version <X.Y.Z> > /tmp/upstream-values.yaml
   helm show values bitnami/redis       --version <A.B.C> > /tmp/redis-values.yaml
   helm show values bitnami/mariadb     --version <D.E.F> > /tmp/mariadb-values.yaml
   ```
3. **Treat these files as the contract.** Mirror **schema and nesting exactly**.

   * **Do not rename** keys.
   * **Do not invent** keys.

---

## Main chart (`ops/helm/<stack>-application/Chart.yaml`)

```yaml
apiVersion: v2
name: <stack>-application
description: House-style wrapper using bjw-s/app-template + optional Bitnami Redis/MariaDB and webgrip common-helpers.
type: application
version: 0.1.0
# Pin the application version if desired for metadata only
appVersion: "5.x" # TODO: pin actual app version

dependencies:
  - name: app-template
    alias: application                 # values go under .Values.application
    version: "X.Y.Z"                   # REQUIRED: pin a specific version
    repository: "oci://ghcr.io/bjw-s/helm"

  - name: common-helpers
    version: "X.Y.Z"                   # REQUIRED: pin a specific version
    repository: "oci://ghcr.io/webgrip/common-charts"

  # Optional deps (enable via values)
  - name: redis
    version: "A.B.C"                   # REQUIRED: pin a specific version
    repository: "oci://registry-1.docker.io/bitnamicharts"
    condition: redis.enabled

  - name: mariadb
    version: "D.E.F"                   # REQUIRED: pin a specific version
    repository: "oci://registry-1.docker.io/bitnamicharts"
    condition: mariadb.enabled
```

---

## Main chart (`ops/helm/<stack>-application/values.yaml`)

> Mirrors `bjw-s/app-template` schema under the `application` alias. Redis/MariaDB use the Bitnami charts’ schema at top level.

```yaml
namespace: <stack>-application

_shared_config:
  hostname: &hostname <stack>-application.staging.k8s.webgrip.nl
  url: &url https://<stack>-application.staging.k8s.webgrip.nl
  image: &image
    repository: docker.io/webgrip/<stack>-application  # org image (ours)
    tag: "latest"                                           # Helm values only; CI/ops pinned elsewhere
    pullPolicy: Always

application:
  enabled: true

  controllers:
    main:
      pod:
        securityContext:
          fsGroup: 1000
          fsGroupChangePolicy: OnRootMismatch
      containers:
        app:
          image: *image
          resources:
            requests: { cpu: "250m", memory: "256Mi" }
            limits:   { cpu: "500m", memory: "512Mi" }
          probes:
            readiness:
              enabled: true
              custom: true
              spec:
                exec:
                  command:
                    ["sh","-c","php -v >/dev/null && nc -z <stack>-application-mariadb 3306"]
                initialDelaySeconds: 10
                periodSeconds: 10
          env:
            - name: APP_ENV
              value: production
            - name: APP_DEBUG
              value: "false"
            - name: APP_URL
              value: *url
            - name: APP_KEY
              valueFrom:
                secretKeyRef:
                  name: <stack>-application-secrets
                  key: app-key
            - name: APP_LOCALE
              value: en
            - name: APP_FALLBACK_LOCALE
              value: en
            - name: APP_TIMEZONE
              value: Europe/Amsterdam
            - name: APP_NAME
              value: "<stack>-application"

            - name: DB_TYPE
              value: mysql
            - name: DB_CONNECTION
              value: mysql
            - name: DB_STRICT
              value: "false"
            - name: DB_HOST
              value: <stack>-application-mariadb
            - name: DB_PORT
              value: "3306"
            - name: DB_DATABASE
              value: <stack>-application
            - name: DB_USERNAME
              value: <stack>-application
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: <stack>-application-secrets
                  key: mariadb-password

            - name: API_SECRET
              valueFrom:
                secretKeyRef:
                  name: <stack>-application-secrets
                  key: api-secret

            - name: REDIS_HOST
              value: <stack>-application-redis-master
            - name: REDIS_PASSWORD
              value: ""
            - name: REDIS_PORT
              value: "6379"
            - name: REDIS_CLIENT
              value: phpredis
            - name: REDIS_PREFIX
              value: <stack>-application_

        web:
          image:
            repository: nginx
            tag: 1.27-alpine
            pullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 80
          resources:
            requests: { cpu: "100m", memory: "128Mi" }
            limits:   { cpu: "300m", memory: "256Mi" }
          probes:
            liveness:
              enabled: true
              custom: true
              spec:
                httpGet: { path: /health, port: http }
                initialDelaySeconds: 5
                periodSeconds: 10
            readiness:
              enabled: true
              custom: true
              spec:
                httpGet: { path: /health, port: http }
                initialDelaySeconds: 2
                periodSeconds: 5

  service:
    main:
      controller: main
      ports:
        http:
          port: 80

  ingress:
    main:
      enabled: true
      className: ingress-traefik
      annotations:
        cert-manager.io/cluster-issuer: letsencrypt-traefik
        # traefik.ingress.kubernetes.io/router.middlewares: "ingress-traefik-ryan-basic-auth@kubernetescrd"
      hosts:
        - host: *hostname
          paths:
            - path: /
              service:
                identifier: main
                port: http
      tls:
        - hosts: [*hostname]
          secretName: letsencrypt-<stack>-application

  persistence:
    public:
      type: persistentVolumeClaim
      enabled: true
      accessMode: ReadWriteOnce
      size: 1Gi
      storageClass: do-block-storage
      globalMounts:
        - path: /var/www/app/public
    storage:
      type: persistentVolumeClaim
      enabled: true
      accessMode: ReadWriteOnce
      size: 2Gi
      storageClass: do-block-storage
      globalMounts:
        - path: /var/www/app/storage
    nginx-conf:
      type: configMap
      enabled: true
      name: <stack>-application  # must match ConfigMap name below
      globalMounts:
        - path: /etc/nginx/conf.d
          readOnly: true

  configMaps:
    nginx:
      enabled: true
      data:
        default.conf: |
          server {
            listen 80;
            root /var/www/app/public;
            index index.php index.html;
            location /health { return 200 'ok'; add_header Content-Type text/plain; }
            location / { try_files $uri /index.php?$query_string; }
            location ~ \.php$ {
              include fastcgi_params;
              fastcgi_pass 127.0.0.1:9000;
              fastcgi_param SCRIPT_FILENAME /var/www/app/public$fastcgi_script_name;
              fastcgi_index index.php;
            }
          }

# Optional dependency: Redis (Bitnami)
redis:
  enabled: true
  architecture: replication
  auth:
    enabled: false
  master:
    persistence:
      enabled: true
      size: 1Gi
  replica:
    replicaCount: 0

# Optional dependency: MariaDB (Bitnami)
mariadb:
  enabled: true
  auth:
    database: <stack>-application
    username: <stack>-application
    existingSecret: <stack>-application-secrets
    secretKeys:
      adminPasswordKey: mariadb-root-password
      userPasswordKey: mariadb-password
  primary:
    persistence:
      enabled: true
      storageClass: do-block-storage
      size: 2Gi
```

---

## Secrets chart (`ops/secrets/<stack>-application-secrets/Chart.yaml`)

```yaml
apiVersion: v2
name: <stack>-application-secrets
description: Secrets for <stack>-application
type: application
version: 0.1.0
appVersion: "1.0.0"
```

## Secrets chart (`ops/secrets/<stack>-application-secrets/values.yaml`)

> Replace with SOPS-encrypted values in your repo. Keys match the `secretKeyRef` usage in the main chart.

```yaml
namespace: <stack>-application

# Kubernetes Secret name to create
name: <stack>-application-secrets

stringData:
  # Application key (32 chars; generate with: php artisan key:generate --show)
  app-key: "base64:secret+secret="  # TODO: rotate

  # MariaDB credentials (names aligned with mariadb.auth.secretKeys + APP env)
  mariadb-password: "secret+secret"         # TODO: rotate
  mariadb-root-password: "secret/secret"    # TODO: rotate

  # Application secrets
  update-secret: "secret"    # TODO: rotate
  webcron-secret: "secret"   # TODO: rotate
  api-secret: "secret"       # TODO: rotate

  # Initial admin bootstrap (if used by your init/seed job)
  user-password: "secret"    # TODO: rotate

  # Mail (optional)
  mail-username: "ryan@webgrip.nl"
  mail-password: "secret+secret"            # TODO: rotate
  # postmark-secret: ""

  # Pusher (optional)
  pusher-app-id: "secret"    # TODO: rotate
  pusher-app-key: "secret"   # TODO: rotate
  pusher-app-secret: "secret" # TODO: rotate
  pusher-app-cluster: "eu"

  # OAuth / S3 / PhantomJS (optional)
  # google-client-secret: ""
  # aws-access-key-id: ""
  # aws-secret-access-key: ""
  # phantomjs-secret: ""
```

---

## Clear operator instructions

1. Open `ops/helm/<stack>-application/values.yaml`.
2. Search for **`# REQUIRED`** (if any remain) and fill placeholders (FQDN, secrets, mail settings, etc.).

   > All sensitive values are already wired via `valueFrom.secretKeyRef`.
3. Ensure Redis/MariaDB are enabled/disabled as needed; verify ports/services match upstream chart defaults.
4. Install in order:

   ```bash
   helm upgrade --install <stack>-application-secrets ops/secrets/<stack>-application-secrets -n <stack>-application --create-namespace
   helm upgrade --install <stack>-application        ops/helm/<stack>-application          -n <stack>-application
   ```

---

## Acceptance checklist

* [ ] Dependency is **official/active** or **`bjw-s/app-template`** fallback is used (all **pinned**; repo URLs recorded).
* [ ] `values.yaml` is **complete**: operator-facing upstream keys present with defaults or `# REQUIRED` placeholders; **no renamed/invented keys**.
* [ ] Image points to **org repo**; `image.tag: "latest"` present **only in Helm values**, with CI/ops pinning elsewhere.
* [ ] Ingress/Service/Ports match upstream; TLS + class follow our standard.
* [ ] Persistence/Redis/MariaDB mirror upstream structure; our defaults applied (storage class/size).
* [ ] Secrets chart exists, installed first; main chart uses `valueFrom.secretKeyRef`.
* [ ] `helm lint` and `helm install --dry-run --debug` both pass.

---

## PR notes

Attach:

* Artifact Hub link(s) for chosen chart(s) and **pinned versions**:

  * `bjw-s/app-template` — version: `<X.Y.Z>` (repo: `oci://ghcr.io/bjw-s/helm`)
  * `bitnami/redis` — version: `<A.B.C>` (repo: `oci://registry-1.docker.io/bitnamicharts`)
  * `bitnami/mariadb` — version: `<D.E.F>` (repo: `oci://registry-1.docker.io/bitnamicharts`)
* `helm show values …` outputs for pinned versions (attach as artifact/gist) to prove key names.
* A short list of any **`# REQUIRED`** fields the operator must fill before install (if any).
