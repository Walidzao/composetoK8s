# Skills Guide: Migrating from Nginx Ingress to NGINX Gateway Fabric

> A step-by-step runbook for teams transitioning from the legacy `ingress-nginx` controller to the Gateway API with NGINX Gateway Fabric v2.x on AWS (kops/EKS).

---

## Prerequisites Checklist

- [ ] Kubernetes >= 1.25
- [ ] Helm v3+ (v4 supported) — required, no standalone YAML manifest in v2.x
- [ ] `kubectl` access to the cluster with admin privileges
- [ ] Note your current ELB hostname (you'll need to update DNS after the switch)
- [ ] Identify all Ingress resources: `kubectl get ingress -A`

---

## Phase 1: Audit Your Current Ingress Setup

### 1.1 — Inventory all Ingress resources

```bash
kubectl get ingress -A -o wide
```

For each Ingress, note:
- **Namespace and name**
- **Host rules** (e.g., `prod.wzops.de`)
- **Paths and backends** (e.g., `/` → `prodapp-svc:8080`)
- **Annotations** — these are the migration risk. Gateway API has no annotations; features are expressed as fields or policy resources

### 1.2 — Identify annotation dependencies

Common nginx-ingress annotations and their Gateway API equivalents:

| Nginx Ingress Annotation | Gateway API Equivalent |
|---|---|
| `nginx.ingress.kubernetes.io/rewrite-target` | HTTPRoute `filters` with `URLRewrite` |
| `nginx.ingress.kubernetes.io/ssl-redirect` | Gateway listener with HTTPS + HTTPRoute redirect filter |
| `nginx.ingress.kubernetes.io/use-regex` | HTTPRoute `path.type: RegularExpression` |
| `nginx.ingress.kubernetes.io/proxy-body-size` | NGINX Gateway Fabric `ClientSettingsPolicy` CRD |
| `nginx.ingress.kubernetes.io/cors-*` | Not yet standardized — use implementation-specific policy |
| `nginx.ingress.kubernetes.io/rate-limit-*` | `BackendTrafficPolicy` (implementation-specific) |

**Rule of thumb**: If your Ingress only uses `host`, `path`, and `backend` — migration is trivial. If it relies heavily on annotations — budget extra time for each one.

### 1.3 — Record your current ELB

```bash
kubectl get svc -n ingress-nginx ingress-nginx-controller \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

Save this — you'll compare it with the new ELB after migration.

---

## Phase 2: Install Gateway API and NGINX Gateway Fabric

### 2.1 — Install Gateway API CRDs

```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/standard-install.yaml
```

Verify:
```bash
kubectl get crd | grep gateway
```

Expected: `gatewayclasses`, `gateways`, `httproutes`, `grpcroutes`, `referencegrants`

### 2.2 — Install NGINX Gateway Fabric via Helm

```bash
helm install ngf oci://ghcr.io/nginx/charts/nginx-gateway-fabric \
  --version 2.4.2 \
  --create-namespace \
  -n nginx-gateway
```

Verify:
```bash
kubectl get pods -n nginx-gateway
kubectl get gatewayclass
```

Expected: controller pod `Running`, GatewayClass `nginx` with `ACCEPTED: True`

> **Important**: No LoadBalancer/ELB is created yet. It's provisioned when you create a Gateway resource.

---

## Phase 3: Translate Ingress Resources to Gateway API

### 3.1 — Translation pattern

**Before (Ingress):**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    nginx.ingress.kubernetes.io/use-regex: "true"
spec:
  ingressClassName: nginx
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-svc
            port:
              number: 8080
```

**After (Gateway + HTTPRoute):**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: my-gateway
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    hostname: example.com
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: my-route
spec:
  parentRefs:
  - name: my-gateway
  hostnames:
  - example.com
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: my-svc
      port: 8080
```

### 3.2 — Key differences

| Concept | Ingress | Gateway API |
|---|---|---|
| Controller selection | `ingressClassName` field | `gatewayClassName` on Gateway |
| Host matching | `rules[].host` | `listeners[].hostname` on Gateway + `hostnames` on HTTPRoute |
| Path matching | `paths[].path` + `pathType` | `rules[].matches[].path` |
| Backend reference | `backend.service.name/port` | `backendRefs[].name/port` |
| TLS | `tls[]` block on Ingress | `listeners[]` with `protocol: HTTPS` + `tls.certificateRefs` on Gateway |
| Custom behavior | Annotations (non-portable) | Filters on HTTPRoute + Policy resources (portable) |

### 3.3 — One Gateway, many HTTPRoutes

Unlike Ingress where each app typically gets its own Ingress resource, Gateway API encourages a shared Gateway with multiple HTTPRoutes:

```
Gateway (port 80, *.example.com)
  ├── HTTPRoute: app-a (app-a.example.com → svc-a:8080)
  ├── HTTPRoute: app-b (app-b.example.com → svc-b:3000)
  └── HTTPRoute: app-c (example.com/api → svc-c:9090)
```

Each team manages their own HTTPRoute. The platform team manages the Gateway.

---

## Phase 4: Cutover

### 4.1 — Apply new resources

```bash
kubectl apply -f gateway.yaml -f httproute.yaml
```

Verify the Gateway is programmed and has an address:
```bash
kubectl get gateway -o wide
```

### 4.2 — Get the new ELB hostname

```bash
kubectl get gateway my-gateway -o jsonpath='{.status.addresses[0].value}'
```

### 4.3 — Test before DNS switch

```bash
curl -H "Host: example.com" http://<new-elb-hostname>/
```

If you get a 200, the new controller is routing correctly.

### 4.4 — Update DNS

Update your DNS record (Cloudflare CNAME, Route 53 Alias, etc.) to point to the new ELB hostname.

### 4.5 — Delete old Ingress resources

```bash
kubectl delete ingress my-ingress
```

### 4.6 — Uninstall old ingress controller

```bash
kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/aws/deploy.yaml
```

Or if you prefer the blunt approach (loses cluster-scoped resources):
```bash
kubectl delete namespace ingress-nginx
```

---

## Phase 5: Verify and Clean Up

```bash
# Confirm no ingress-nginx remnants
kubectl get ns ingress-nginx 2>&1          # Should be NotFound
kubectl get ingressclass 2>&1              # Should show only 'nginx' from Gateway Fabric
kubectl get validatingwebhookconfiguration # No ingress-nginx entries

# Confirm Gateway API is healthy
kubectl get gatewayclass                   # ACCEPTED: True
kubectl get gateway                        # PROGRAMMED: True, ADDRESS populated
kubectl get httproute                      # HOSTNAMES populated

# Confirm app is reachable
curl -I https://your-domain.com
```

---

## Troubleshooting

### "Gateway has no ADDRESS"
The LoadBalancer Service hasn't been provisioned. Check:
```bash
kubectl get svc -n nginx-gateway
kubectl describe gateway my-gateway
```
Look for events indicating cloud provider errors (IAM permissions, subnet tags, etc.)

### "HTTPRoute not accepted"
```bash
kubectl describe httproute my-route
```
Common causes: parentRef doesn't match a Gateway name, or the hostname doesn't match a Gateway listener.

### Old ELB still lingering in AWS
If you deleted the ingress controller but the NLB persists in AWS:
```bash
aws elbv2 describe-load-balancers --query 'LoadBalancers[?contains(DNSName, `old-elb-prefix`)]'
```
Kubernetes should garbage-collect it, but if not, check the cloud-controller-manager logs.

---

## Known Pitfalls (as of March 2026)

1. **Broken URLs everywhere** — NGINX Gateway Fabric moved from `github.com/nginxinc` to `github.com/nginx` and dropped the YAML manifest. Most online tutorials are outdated.

2. **Helm-only in v2.x** — If your org restricts Helm, the manifest-based install requires cert-manager as a prerequisite (for internal mTLS between controller and agent sidecar).

3. **OCI registry, not traditional Helm repo** — `helm repo add` doesn't work. Use `oci://ghcr.io/nginx/charts/nginx-gateway-fabric` directly in `helm install`.

4. **No NLB until Gateway creation** — Unlike the ingress controller which provisions a LoadBalancer on install, NGINX Gateway Fabric waits until a Gateway resource is created. Don't panic when `kubectl get svc` shows ClusterIP only.

5. **Annotation gap** — Some ingress-nginx annotations have no Gateway API equivalent yet. Check the [NGINX Gateway Fabric policy docs](https://docs.nginx.com/nginx-gateway-fabric/) for implementation-specific CRDs.

---

## Quick Reference: Switching Gateway API Implementations

The portability promise of Gateway API: change the `gatewayClassName` and the implementation switches. The HTTPRoute stays the same.

```yaml
# NGINX Gateway Fabric
gatewayClassName: nginx
controllerName: gateway.nginx.org/nginx-gateway-controller

# Istio
gatewayClassName: istio
controllerName: istio.io/gateway-controller

# Cilium
gatewayClassName: cilium
controllerName: io.cilium/gateway-controller

# Envoy Gateway
gatewayClassName: eg
controllerName: gateway.envoyproxy.io/gatewayclass-controller
```

In theory, switching is one field change. In practice, each implementation has different:
- Installation requirements (Helm charts, operators, CRDs)
- Policy CRDs for advanced features (rate limiting, auth, retries)
- LoadBalancer provisioning behavior
- TLS certificate handling

The HTTPRoute is portable. The operational toil around it is not — yet.
