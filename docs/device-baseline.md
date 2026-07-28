# Device baseline

Observed 2026-07-28 UTC:

- PCI `01:00.0`, Intel `8086:e223`, reported as Battlemage G31 / Arc Pro B70
- Kernel driver `xe`
- `/dev/dri/renderD128`, `root:render`, `0660`
- Intel iHD VA driver 26.1.2 through libva 1.23
- VA-API AV1 Profile 0 encode capability
- Ubuntu FFmpeg 8.0.1 with libvpl and VA-API support

The operator belongs to `render` and `video`; a pre-existing login may need a
fresh session (or bounded `sg render`) before supplementary groups take effect.

