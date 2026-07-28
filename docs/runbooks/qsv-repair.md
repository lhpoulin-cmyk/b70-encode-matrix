# QSV repair runbook and investigation

QSV is additive and experimental. Preflight on 2026-07-28 found Ubuntu FFmpeg
8.0.1 at `/usr/bin/ffmpeg`, built `--enable-libvpl --disable-libmfx`, exposing
both AV1 hardware encoders. `libvpl2 2.16.0-1` was installed, but
`libmfx-gen1.2` and `libvpl-tools` were absent. iHD VA-API remained healthy.

With valid render-group access, both requested paths loaded iHD and reached
oneVPL API 2.15, then failed to create an MFX session with `MFX error -9`:

- direct: `qsv=qs:hw,child_device=/dev/dri/renderD128`
- derived: `vaapi=va:/dev/dri/renderD128` then `qsv=qs@va`

The root cause was a runtime-discovery problem: the Intel GPU oneVPL
implementation was missing. The reviewed Ubuntu transaction added only
`libmfx-gen1.2 26.1.2-1` and `libvpl-tools 1.5.0-1`, with no removals or
upgrades. Rollback is removal of those two newly added packages; do not remove
iHD, libvpl2, or FFmpeg.

After installation, `vpl-inspect` detected `mfx-gen`, API 2.16, VA-API
acceleration, device `e223/0`, and AV1 Main encode. Both direct and derived
commands completed 300-frame AV1 Main encodes; FFprobe passed, complete decode
returned zero, and checksums were recorded:

- direct: `c028d71c830e06e4f2b88f66b012645cd63ee55f07739eb84cb89999f36a91be`
- derived: `918f0f13809e9655cc43194449c83de1fd626dab9ed64f8931f13ecdd33d91aa`

The supported experimental direct initialization is:

```bash
ffmpeg -hide_banner -loglevel verbose \
  -init_hw_device qsv=qs:hw,child_device=/dev/dri/renderD128 \
  -filter_hw_device qs -f lavfi \
  -i 'testsrc2=size=1920x1080:rate=30' -t 10 \
  -vf 'format=nv12,hwupload=extra_hw_frames=64' \
  -c:v av1_qsv -b:v 5M -y av1-qsv-direct.mkv
```

This is classification A (fully repaired), but it remains experimental until
representative-media acceptance testing. VA-API stays the production default.

After any repair, preserve complete `vpl-inspect`, direct and derived logs. A
successful file must be probed, fully decoded, and checksummed. Always rerun the
VA-API production regression afterward. If packaged discovery works but both
QSV paths still fail, record the observed stack as unsupported rather than
destabilizing VA-API or adding a repository. The post-repair VA-API regression
passed and hashed to
`b830f57f7140ce1d75a72717acb7bc2b04ec012837616917a65c1000a5297fcd`.
