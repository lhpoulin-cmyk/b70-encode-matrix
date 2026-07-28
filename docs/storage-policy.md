# Storage policy

`/srv/b70-encode` stores software, configuration, bounded tests, evidence, job
state, and temporary work—not a permanent media library. `scratch/`, `tmp/`,
and generated fixtures are disposable and Git-ignored.

Reserved external paths are `/mnt/media/source` (read-only originals whenever
practical), `/mnt/media/work` (high-volume temporary work),
`/mnt/media/output` (validated or staged output), and `/mnt/media/archive`
(approved retention). No mount or `/etc/fstab` entry is created without
authorization. A directory's existence does not prove it is mounted; verify
with `findmnt` before access.

Before substantial output check destination filesystem, bytes, inodes,
expected output, scratch use, and mount state. Local workspace storage must
retain both 30 GiB and 20 percent free (equivalently, meet the larger reserve).
Never accidentally redirect a large encode to the root filesystem when an
external mount is absent.

