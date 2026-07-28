# Helix-ARPA GPU Encode Appliance

This repository is the source of truth for a reusable, dedicated GPU media
pipeline appliance. It contains policy, bootstrap logic, hardware profiles,
operator commands, cloud-init examples, validation tests, and reviewed Proxmox
deployment tooling.

The appliance has three deliberately separate layers:

```text
VM 310                 working B70 reference implementation
this Git repository    authoritative reusable appliance source
VM 9310                proposed clean generic Ubuntu template, built separately
```

VM 310 proves the contract and remains a normal production VM. It is never the
clone source. VM 9310 contains no GPU, raw disk, instance identity, credentials,
evidence, or media. A private deployment profile assigns the real host, GPU
resource mapping, storage, network, and identity to a clone. Acceptance tests
then promote that clone into an appliance.

Production on the reference instance is explicit Intel VA-API AV1 through
`/dev/dri/renderD128` and `av1_vaapi`. QSV is repaired and synthetically
validated but remains experimental pending representative-media acceptance.

Operator entry points are `bin/doctor`, `bin/probe`, `bin/encode`,
`bin/validate-output`, and `bin/collect-evidence`. Bootstrap begins with
`bootstrap/install.sh --dry-run --profile config/profiles/intel-battlemage/profile.yaml`.
Host-side scripts under `proxmox/` render or perform only explicitly authorized
Proxmox operations; they must not be executed from VM 310.

Read `AGENTS.md`, `docs/appliance-contract.md`, and
`docs/reference-implementation.md` before changing a deployed instance.
