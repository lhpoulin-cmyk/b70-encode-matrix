# Deployment

A real deployment profile supplies release/template, target VM identity and
node, CPU/memory, bridge, logical GPU resource mapping, hardware profile,
storage, network, and media policy. Generic source never contains the physical
PCI address. Define mappings in Proxmox under **Datacenter → Resource Mappings
→ PCI Devices**, for example `gpu-encode-b70`.

Run `proxmox/deploy-instance.sh --dry-run --profile PRIVATE.yaml`; after review,
run with `--apply`. Supported controls are `--dry-run`, `--profile`,
`--no-start`, and `--skip-gpu`. The script clones only the configured generic
template (9310 in the example), configures identity/resources/cloud-init,
attaches the logical GPU mapping and optional scratch, starts when allowed, and
prints guest bootstrap/finalization steps. It validates unresolved placeholders,
template/target/name/storage/resource mapping/cloud-init inputs, and exclusive
mapping use before mutation.

Real profiles should live separately, for example
`helix-arpa-infra/nodes/hv-matrix/gpu-encode-b70.yaml`. Do not commit them here.
Acceptance, not cloning, promotes the instance. Rollback stops and destroys only
the failed new clone after evidence capture; it does not change the template or
VM 310.
