# MetalLB on k3s

Installs [MetalLB](https://metallb.universe.tf/) in L2 mode on a k3s cluster, replacing the built-in Klipper servicelb.

## Prerequisites

Disable Klipper (k3s's built-in load balancer) when installing k3s:

```console
# k3s install with servicelb disabled
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable servicelb" sh -
```

## Files

| File | Purpose |
|---|---|
| `apply.sh` | Install MetalLB from vendored manifests |
| `delete.sh` | Remove MetalLB (handles stuck finalizers from webhooks) |
| `manifests/metallb-native.yaml` | Vendored MetalLB v0.16.0 (webhook `failurePolicy` patched to `Ignore`) |
| `manifests/ipaddresspool.yaml` | IPAddressPool + L2Advertisement (edit the IP range here) |

## Install

```console
# Default IP range (192.168.0.2-192.168.0.29)
./apply.sh

# Custom IP range
./apply.sh 192.168.1.100 192.168.1.120

# Or via env vars
METALLB_IP_START=10.0.0.5 METALLB_IP_END=10.0.0.50 ./apply.sh
```

**The IP range must be reserved and NOT handed out by your DHCP server.** MetalLB answers ARP for these IPs when a `LoadBalancer`-typed Service requests one.

## Delete

```console
./delete.sh
```

Handles the stuck-namespace problem (webhook finalizers) by patching out finalizers if the namespace hangs in `Terminating`.

## Why the webhook `failurePolicy` patch

MetalLB ships with `failurePolicy: Fail` on its validating/mutating webhooks. On k3s, this can block resource creation when the webhook server isn't ready (timing race on fresh installs / restarts). The vendored manifest pre-patches all 6 webhooks to `failurePolicy: Ignore`, which is the recommended k3s workaround.

## Prometheus scraping — known gotcha

MetalLB v0.16.0 exposes metrics on port **9120 over HTTPS** (the port is literally named `metricshttps` in the pod spec). The upstream manifest bakes in `prometheus.io/scrape: "true"` + `prometheus.io/port: "9120"` annotations, but **annotation-based scraping defaults to HTTP** and can't set `scheme: https` per-target. This means:

- A Prometheus scrape config that filters on `prometheus.io/scrape=true` will hit MetalLB on HTTP and get HTTP 400
- To actually scrape MetalLB, you need a dedicated job with `scheme: https` + `tls_config.insecure_skip_verify: true`

Example scrape job (add to your Prometheus config):
```yaml
- job_name: 'metallb'
  scheme: https
  tls_config:
    insecure_skip_verify: true
  kubernetes_sd_configs:
    - role: pod
      namespaces:
        names: [metallb-system]
  relabel_configs:
    - source_labels: [__meta_kubernetes_pod_label_app]
      action: keep
      regex: metallb
    - source_labels: [__address__, __meta_kubernetes_pod_container_port_number]
      action: replace
      regex: ([^:]+)(?::\d+)?;9120
      replacement: $1:9120
      target_label: __address__
```

## Versions

- MetalLB: **v0.16.0** (vendored in `manifests/metallb-native.yaml`)
- To upgrade: replace the vendored manifest with the new version's `metallb-native.yaml`, re-apply the `failurePolicy: Ignore` patch, bump the version note here.
