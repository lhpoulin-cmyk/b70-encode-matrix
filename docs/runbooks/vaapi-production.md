# VA-API production runbook

Production is `xe → iHD → VA-API → av1_vaapi` on
`/dev/dri/renderD128`. Confirm access and `vainfo --display drm --device
/dev/dri/renderD128`, then use an explicit device:

```bash
ffmpeg -hide_banner -loglevel verbose \
  -vaapi_device /dev/dri/renderD128 -i INPUT \
  -vf 'format=nv12,hwupload' -c:v av1_vaapi -b:v 5M OUTPUT.part.mkv
```

Adapt stream mapping only from an inspected job policy. Validate with
`bin/validate-output`, retain the verbose log proving `av1_vaapi`, record the
checksum, then atomically promote. Never silently use QSV or software.

The post-QSV-repair 2026-07-28 synthetic regression encoded 300 1920x1080p30
frames as AV1 Main, fully decoded, and produced SHA-256
`b830f57f7140ce1d75a72717acb7bc2b04ec012837616917a65c1000a5297fcd`.

