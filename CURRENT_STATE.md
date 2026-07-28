# Current state

Observed 2026-07-28 UTC on VMID 310, the Helix-ARPA GPU Encode Reference
Implementation. Proxmox name is `b70-encode`; the guest hostname is
`b70-encode-matrix`.

- OS: Ubuntu 26.04 LTS; kernel `7.0.0-28-generic`
- GPU: Intel Arc Pro B70 / `8086:e223`; kernel driver `xe`
- Render node: `/dev/dri/renderD128`, `root:render`, mode `0660`
- VA-API: libva 1.23, Intel iHD 26.1.2, AV1 Profile 0 encode exposed
- FFmpeg: `/usr/bin/ffmpeg`, Ubuntu `8.0.1-3ubuntu2`, `--enable-libvpl`,
  `--disable-libmfx`, `av1_vaapi` and `av1_qsv` exposed
- oneVPL: `libvpl2 2.16.0-1`, `libmfx-gen1.2 26.1.2-1`, tools 1.5.0
- MakeMKV: 1.18.3 and `makemkvcon` available
- Production: explicit VA-API `av1_vaapi`
- Experimental: QSV `av1_qsv`, synthetically validated direct and VA-derived;
  representative-media acceptance incomplete

Productization pre-change regression used a ten-second 1920x1080p30 NV12
synthetic input. iHD and `VAProfileAV1Profile0/EncSlice` were observed; FFmpeg
logged `av1_vaapi`; output was AV1 Main 1920x1080p30/yuv420p, fully decoded, and
hashed to `f1122d0b408d22cf6c208bead5125542abf6c394db1040a4f8b87d1040df0ccf`.

Post-restructure appliance smoke passed. The mandatory production regression
again logged iHD and `av1_vaapi`; AV1 Main output probed correctly, the complete
decode log was empty, and SHA-256 was
`e2e378f686e8a49dcadd44eabf609bee3c2a736b4780905c275ea7d9fe00c44e`.
Generic bootstrap dry-run, template-command rendering, deployment-command
rendering, unsupported-profile refusal, unresolved-placeholder refusal, and
reference-VM sanitization refusal passed. ShellCheck is unavailable; all shell
files passed `bash -n`.

The optional post-restructure QSV regression also passed through mfx-gen 2.16:
AV1 Main probed and fully decoded with SHA-256
`eb99307985a00c593712fc6f736e61065ac52278a99a5fe955f2fe7116f3fd29`.
This confirms experimental availability but does not change production policy.

VM 310 remains a normal reference/production VM and is not a template or clone
source. The reusable repository now separates generic appliance source,
hardware profiles, and private deployment facts. VM 9310 is only a reviewed
host-side template proposal; no Proxmox operation was performed.

Known limitations: representative bit-depth/HDR/audio/subtitle/performance and
thermal acceptance remain; non-Battlemage profiles are placeholders; the
private deployment repository/URL has not been supplied. Reserved `/mnt/media`
directories still require one privileged creation command because this session
has no cached sudo authentication. The existing public
`origin` is retained unchanged and no productization commit is pushed to it.
