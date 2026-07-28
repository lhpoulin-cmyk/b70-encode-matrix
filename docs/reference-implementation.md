# Helix-ARPA GPU Encode Reference Implementation

VMID 310, Proxmox name `b70-encode`, is the working implementation reference on
`hv-matrix`. The guest currently reports hostname `b70-encode-matrix`, Ubuntu
26.04 LTS, kernel 7.0.0-28-generic, Intel Arc Pro B70 (`8086:e223`), `xe`, Intel
iHD 26.1.2, and `/dev/dri/renderD128`.

The supported production path is `xe → iHD → VA-API → av1_vaapi`. QSV through
oneVPL/mfx-gen is synthetically validated but remains experimental until
representative acceptance. MakeMKV 1.18.3 and `makemkvcon` are present. The
workspace is `/srv/b70-encode`; the repository began from commit `8339a66`.

The storage contract supports a dedicated raw-partition or other instance
scratch assignment supplied privately at deployment, plus external source,
work, output, and archive mounts. Generic source never names the physical WD
SN810 device or a PCI address. Current host-specific assumptions include VMID,
Proxmox node, passthrough assignment, render-node enumeration, storage mapping,
network identity, and operator access; these belong in private infrastructure
state, not reusable bootstrap.

Completed evidence includes B70 discovery, `xe`, render access, iHD/AV1 encode
exposure, repeated ten-second hardware AV1 encodes, FFprobe, complete decode,
SHA-256, oneVPL discovery and QSV tests, and MakeMKV availability. Remaining
limitations are representative-media acceptance, HDR/bit-depth/audio/subtitle
coverage, performance/thermal baselines, and appliance-clone acceptance.

VM 310 is not the clone source and must never be converted to a template. It
remains a normal production-capable VM used to prove the appliance contract.
