# Architecture

```text
VM 310 reference ──proves──> Git source of truth
                                  │
                                  ├──builds──> VM 9310 generic image
                                  │                 │
private deployment profile ──────┴──assigns────────┤
                                                    v
                               clone + GPU/storage/network/identity
                                                    │
                                      acceptance tests promote it
```

VM 310 stays attached to the B70 because it is the known-good operational
reference and regression target. VM 9310 is separately built without physical
GPU, raw storage, identity, credentials, or runtime history so clones do not
inherit exclusive resources or secrets. Git is authoritative because images
are opaque artifacts; policy, scripts, profiles, tests, and release provenance
must remain reviewable and reproducible.

Hardware profiles describe portable media-stack expectations. Private
deployment profiles assign a real Proxmox node, logical GPU resource mapping,
storage, network, and identity. This separation prevents generic code from
encoding host PCI addresses or disk paths. A clone is only an appliance after
its observed hardware and media behavior pass acceptance and generate instance
state.

Runtime media flow remains `source → ingest → inspect → job manifest → explicit
hardware encode → probe → decode validation → checksum → output staging →
promotion → evidence`.
