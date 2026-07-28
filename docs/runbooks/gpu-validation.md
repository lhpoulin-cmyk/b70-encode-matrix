# GPU validation

Run `bin/doctor`, confirm PCI `8086:e223` uses `xe`, verify render-node access,
and run DRM-mode `vainfo` with iHD. Then run `tests/smoke/vaapi-av1`; require
encoder success, FFprobe recognition, full decode, checksum, and verbose-log
evidence of `av1_vaapi`. Stop on device identity changes or any fallback.

