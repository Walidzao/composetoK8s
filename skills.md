# Gateway API Migration Skills

## Nginx Ingress → Gateway API (any implementation)

- Ingress maps to two resources: Gateway (listener config) + HTTPRoute (routing rules)
- `ingressClassName` becomes `gatewayClassName` on the Gateway — not on the HTTPRoute
- HTTPRoute is portable across implementations. Gateway is mostly portable. GatewayClass is implementation-specific.
- Annotations do not exist in Gateway API. Translate them to HTTPRoute `filters` or implementation-specific policy CRDs.
- Delete the old Ingress resource after the HTTPRoute is confirmed working — it becomes orphaned, not harmful

## NGINX Gateway Fabric (v2.x)

- Helm-only install. No standalone YAML manifest. Do not search for one.
- OCI chart: `oci://ghcr.io/nginx/charts/nginx-gateway-fabric`. No `helm repo add` step.
- GitHub org moved from `nginxinc` to `nginx` — most online tutorials have broken URLs
- Install Gateway API CRDs first: `kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/standard-install.yaml`
- The GatewayClass name is `nginx`, controller is `gateway.nginx.org/nginx-gateway-controller`
- No LoadBalancer/ELB is created on install. It is provisioned only when a Gateway resource is applied.

## Cilium as Gateway API controller

- If the cluster CNI is Cilium, it can serve as the Gateway API controller with zero extra pods
- Enable via kops spec or Helm values: `gatewayAPI.enabled: true`
- GatewayClass name: `cilium`, controller: `io.cilium/gateway-controller`
- Handles traffic at eBPF layer — no proxy pod, lower latency

## Istio as Gateway API controller

- Install Istio first (`istioctl install` or Helm)
- GatewayClass name: `istio`, controller: `istio.io/gateway-controller`
- Istio provisions its own gateway pod per Gateway resource
- Adds service mesh capabilities (mTLS, observability) beyond routing

## Switching between implementations

- Only `gatewayClassName` on the Gateway resource changes. HTTPRoute stays identical.
- Each switch provisions a new ELB — update DNS after every switch
- Uninstall the previous controller after confirming the new one works
- Test before DNS cutover: `curl -H "Host: <domain>" http://<new-elb>/`

## DNS after migration

- New controller = new ELB hostname. Always update Route 53 Alias or Cloudflare CNAME.
- Get new address: `kubectl get gateway <name> -o jsonpath='{.status.addresses[0].value}'`
- Allow TTL to expire or flush local DNS cache after updating

## TLS with Gateway API

- Add an HTTPS listener on port 443 with `tls.mode: Terminate` and a `certificateRefs` Secret
- Use cert-manager + Let's Encrypt to automate certificate provisioning
- cert-manager creates the Secret; the Gateway references it. No manual cert management.
- Without a valid cert, browsers show the same self-signed error as with the old ingress controller
