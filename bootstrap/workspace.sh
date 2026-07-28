#!/usr/bin/env bash
set -Eeuo pipefail

root=/srv/b70-encode
operator=${SUDO_USER:-${USER:-}}
dry_run=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --operator) operator=${2:?missing operator}; shift 2 ;;
    --dry-run) dry_run=true; shift ;;
    --apply) dry_run=false; shift ;;
    *) echo "usage: workspace.sh [--operator USER] [--dry-run|--apply]" >&2; exit 64 ;;
  esac
done
[[ -n "$operator" ]] || { echo "cannot determine operator account" >&2; exit 65; }
directories=(bin bootstrap cloud-init config/profiles config/systemd config/examples docs/runbooks evidence jobs/queued jobs/running jobs/succeeded jobs/failed lib logs pipelines/ingest pipelines/inspect pipelines/transcode pipelines/validate pipelines/publish proxmox scratch/input scratch/work scratch/output tests/smoke tests/regression tests/acceptance tests/fixtures/generated tests/results tmp)

if $dry_run; then
  echo "would ensure group media-pipeline and operator $operator membership"
  echo "would ensure canonical directories below $root"
  echo "would reserve /mnt/media/{source,work,output,archive} without mounting"
  echo "would set directories 2775, files 0664, scripts 0755; no world-writable paths"
  exit 0
fi
[[ $EUID -eq 0 ]] || { echo "workspace installation requires root; use --dry-run to inspect" >&2; exit 77; }
getent group media-pipeline >/dev/null || groupadd media-pipeline
id "$operator" >/dev/null 2>&1 || { echo "operator does not exist: $operator" >&2; exit 67; }
usermod -aG media-pipeline "$operator"
install -d -o "$operator" -g media-pipeline -m 2775 "$root"
install -d -o root -g media-pipeline -m 2775 /mnt/media /mnt/media/source /mnt/media/work /mnt/media/output /mnt/media/archive
for directory in "${directories[@]}"; do install -d -o "$operator" -g media-pipeline -m 2775 "$root/$directory"; done
chown -R "$operator":media-pipeline "$root"
find "$root" -type d -exec chmod 2775 {} +
find "$root" -type f -exec chmod 0664 {} +
find "$root/bin" -type f -exec chmod 0755 {} +
find "$root/bootstrap" "$root/proxmox" "$root/lib" -type f -name '*.sh' -exec chmod 0755 {} +
find "$root/tests/smoke" "$root/tests/regression" "$root/tests/acceptance" -type f ! -name '*.md' -exec chmod 0755 {} +
for directory in evidence jobs/queued jobs/running jobs/succeeded jobs/failed logs scratch/input scratch/work scratch/output tests/fixtures/generated tests/results tmp; do
  install -o "$operator" -g media-pipeline -m 0664 /dev/null "$root/$directory/.gitkeep"
done
if find "$root" -xdev -perm -0002 -print -quit | grep -q .; then
  echo "refusing world-writable workspace paths" >&2
  exit 73
fi
