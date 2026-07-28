# Changelog

## 2026-07-28

- Productized the B70 reference implementation as the reusable Helix-ARPA GPU
  Encode Appliance pattern.
- Added generalized doctrine, appliance contract, hardware profiles, bootstrap,
  cloud-init examples, layered tests, release process, and reviewed Proxmox
  template/deployment tooling.
- Established the canonical workspace, operating doctrine, operator commands,
  policies, runbooks, profiles, and smoke test.
- Evaluated packaged FFmpeg QSV direct and VA-derived initialization.
- Installed the missing Ubuntu `libmfx-gen1.2` implementation and
  `libvpl-tools`; direct and VA-derived AV1 QSV now validate successfully.
- Preserved VA-API AV1 as the production default and regression-tested it.
