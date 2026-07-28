# Current state

Observed 2026-07-28 UTC on `b70-encode-matrix` (operator-confirmed identity).

- OS: Ubuntu 26.04 LTS (Resolute)
- Kernel: `7.0.0-28-generic`
- GPU: Intel Battlemage G31 / Arc Pro B70, PCI `8086:e223` at `01:00.0`
- Kernel driver: `xe`
- Render node: `/dev/dri/renderD128`, `root:render`, mode `0660`
- VA-API: libva 1.23; Intel iHD 26.1.2; AV1 Profile 0 encode exposed
- FFmpeg: `/usr/bin/ffmpeg`, Ubuntu `8.0.1-3ubuntu2`
- FFmpeg build: `--enable-libvpl`, `--disable-libmfx`; both `av1_qsv` and
  `av1_vaapi` exposed
- oneVPL dispatcher: `libvpl2 2.16.0-1`
- Intel VA runtime: `intel-media-va-driver-non-free 26.1.2+ds1-1`
- MakeMKV: 1.18.3; `makemkvcon` available (currently reports its application
  version as too old for unregistered operation)
- Intel oneVPL implementation: `libmfx-gen1.2 26.1.2-1`; tools
  `libvpl-tools 1.5.0-1`
- QSV: fully repaired. `vpl-inspect` detects `mfx-gen`, API 2.16, VA-API
  acceleration, device `e223/0`, and AV1 Main encoding. Direct and VA-derived
  10-second 1920x1080p30 NV12 `av1_qsv` tests both encoded and fully decoded.
  Direct SHA-256: `c028d71c830e06e4f2b88f66b012645cd63ee55f07739eb84cb89999f36a91be`;
  derived SHA-256: `918f0f13809e9655cc43194449c83de1fd626dab9ed64f8931f13ecdd33d91aa`
- Post-repair VA-API regression: 10-second 1920x1080p30 NV12 `av1_vaapi`,
  AV1 Main, successful full decode; SHA-256
  `b830f57f7140ce1d75a72717acb7bc2b04ec012837616917a65c1000a5297fcd`

Production remains explicit VA-API. QSV is a repaired but experimental additive
path pending representative-media acceptance testing. The current interactive
session may require `sg render` or a fresh login to activate recently configured
device groups.
