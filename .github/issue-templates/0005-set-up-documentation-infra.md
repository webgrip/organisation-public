# Architecture & System Intent Documentation Request

> Goal: Commission a single authoritative architecture & intent document (≤2000 words) that explains WHAT exists, WHY it exists, and HOW it coheres—grounded in this repo plus authoritative external sources for referenced technologies.

---

## 1. Deliverable

Produce `docs/techdocs/docs/architecture/architecture-intent.md` (or update if exists) containing:

1. Purpose (≤40 words)  
2. Executive Snapshot (bullet high‑level: systems, infra, runtime context)  
3. Conceptual Architecture (narrative + optional mermaid)  
4. Domain & Problem Framing (what user / business problems are solved)  
5. System Components & Responsibilities (each: intent, key tech, rationale)  
6. External Dependencies & Rationale (why chosen vs common alternatives)  
7. Cross‑Cutting Concerns  
   - Configuration strategy  
   - Observability (what signals mean what)  
   - Security posture (surface, isolation, secrets approach)  
8. Operational Model  
   - Deployment flow & environments  
   - Scaling & resilience levers  
9. Evolution & Constraints  
   - Explicit trade‑offs  
   - Known debt / intentional simplifications  
10. Glossary (only terms actually used)  
11. Reference Footnotes (indexed, authoritative sources only)

Hard limits:  
- Total ≤2000 words (exclude footnotes list, code fences, diagrams)  
- Each component description ≤70 words  
- No filler (“robust”, “best-of-breed”)—state facts & intent  

---

## 2. Sources to Consult

Priority order (cite with footnotes):  
1. Repository contents (code, Helm charts, manifests, ADRs if any)  
2. Commit messages referencing foundational setup  
3. Official documentation for named tools (e.g., cert-manager, Traefik, GitHub Actions runner controller, Grafana stack, Prometheus, Loki, Mimir, Tempo)  
4. CNCF / vendor architecture references (only if directly relevant)  
5. Industry-standard definitions (e.g., “ingress controller”, “observability pipeline”)  

Never cite: blogs without primary documentation, AI speculation, unverified forums.

If intent is unclear: state “Assumed intent: … (evidence: path/file)”—do not fabricate certainty.

---

## 3. Required Analytical Passes

| Pass | Objective | Output Artifact (temp) |
|------|-----------|------------------------|
| Inventory | Enumerate clusters, controllers, charts, services | components-inventory.tmp |
| Infra Mapping | Link Helm chart dirs → deployed capability | infra-map.tmp |
| Dependency Semantics | For each tool, extract role + why it fits ecosystem | deps-role.tmp |
| Cross-Cutting Extraction | Logging, metrics, tracing, cert issuance, routing, runners | cross-cutting.tmp |
| Intent Derivation | Infer “why” from structure + naming + composition | intent-hypotheses.tmp |
| Vocabulary Harvest | Collect domain / ops terms | glossary-draft.tmp |

Delete temp artifacts after merge (do not commit).

---

## 4. Technology Buckets to Interpret

| Bucket | Examples in Repo | Clarify Meaning |
|--------|------------------|-----------------|
| Ingress / Edge | Traefik, NGINX (experimental) | Traffic routing, TLS termination, middleware policies |
| Cert & PKI | cert-manager, issuers | Automated certificate lifecycle & trust anchors |
| Observability | Prometheus stack, Alloy, Loki, Mimir, Tempo, Grafana | Metrics, logs, traces, dashboards—correlation intent |
| CI Runtime | GitHub Actions runner controller & scale sets | Elastic ephemeral build/CI capacity |
| Secrets / Security | (Secrets dirs, akeyless experimental) | Secret injection pattern & variance |
| Example Services | echo, quote | Baseline service topology / ingress patterns |
| Cluster Ops | Metrics server, tainters | Scheduling & autoscaling signals |

For each: articulate *why it must exist together* (compositional intent).

---

## 5. Structural & Style Rules

- Headings start at `##` (no `#` inside body doc)  
- Active voice; no future tense unless roadmap  
- Prefer: “X enables Y by Z”  
- Mermaid allowed (`graph TD`, sequence) if clarifies (word count excludes code fences)  
- Footnotes: numeric under `## References`  
- Backticks for literal identifiers (dirs, resource kinds)  
- Relative links to internal docs when they exist  
- No external images; no marketing adjectives  
- “Last Reviewed: YYYY-MM-DD” near top  
- Accessibility: semantic headings, descriptive alt text if any media, table headers used  
- Security: redact/replace secrets with `<REDACTED>` / `<PLACEHOLDER>`  

---

## 6. Online Lookup Guidance

For each external component:  
1. Retrieve official definition (landing/docs)  
2. Paraphrase minimal clarifying role (no large quotes)  
3. Contrast repo usage vs canonical pattern (note deviations)  
4. Footnote URL (deduplicate)  

If overlapping tools (e.g., Traefik + NGINX): state hypothesized rationale (e.g., evaluation, fallback).

---

## 7. Decision & Intent Framing Template

Use inline micro-template (not full ADR) for implicit decisions:

```
Decision: Adopt <tool/practice> for <problem>. Intent: Enable <desired property>. Alternatives (implicit): <alt1>, <alt2> (not chosen due to <reason>). Evidence: <path or chart dir>
```


≤40 words per block; only when it clarifies.

---

## 8. Risk / Trade-off Categories

| Category | Prompt |
|----------|--------|
| Complexity | Does multi-layer observability add ops burden? |
| Vendor / API Drift | Upgrade exposure & version pinning |
| Scale Characteristics | Horizontal vs vertical scaling pressures |
| Reliability | Single ingress or control plane chokepoints |
| Security | Secret distribution surface / cert chain risks |
| Operational Load | Manual rotation / bootstrap tasks |

Include only if evidence-backed.

---

## 9. Completion Checklist

- [ ] Word count ≤2000 (excluding footnotes, fenced code, diagrams)  
- [ ] Every major directory category referenced  
- [ ] Each external tech: role + rationale/assumption  
- [ ] Cohesive topology (diagram or precise prose)  
- [ ] Cross-cutting concerns each have intent statement  
- [ ] No unverifiable claims  
- [ ] References section present & deduplicated  
- [ ] Glossary terms appear ≥2× (else trimmed)  
- [ ] Implicit decisions framed where needed  

---

## 10. Failure Conditions (Reject & Revise)

- Speculation without “Assumed” qualifier  
- Marketing adjectives / filler  
- Missing rationale for any critical component
- >2000 word body
- Non-authoritative or missing external sources
- Duplicate tooling unexplained

---

## 11. Submission Notes

Prefer concise acknowledged uncertainty over fabricated linkage. Tightness > breadth.

---

## 12. References Section Structure (Example)

```
[1] Traefik – Official Docs https://doc.traefik.io/ 
[2] cert-manager – Project Site https://cert-manager.io/ 
[3] Prometheus – Overview https://prometheus.io/docs/introduction/overview/ ...
```

