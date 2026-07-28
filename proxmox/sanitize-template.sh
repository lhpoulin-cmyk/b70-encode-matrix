#!/usr/bin/env bash
set -Eeuo pipefail

expected_hostname= apply=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --expected-hostname) expected_hostname=${2:?}; shift 2 ;;
    --dry-run) apply=false; shift ;;
    --apply) apply=true; shift ;;
    *) echo "usage: sanitize-template.sh --expected-hostname NAME [--dry-run|--apply]" >&2; exit 64 ;;
  esac
done
[[ -n "$expected_hostname" ]] || { echo "expected hostname is required" >&2; exit 64; }
actual=$(hostname -s)
build=/srv/b70-encode/BUILD
marker=/etc/b70-encode-template-candidate
[[ "$actual" == "$expected_hostname" ]] || { echo "hostname mismatch: expected=$expected_hostname actual=$actual" >&2; exit 77; }
if [[ "$actual" == b70-encode || "$actual" == b70-encode-* ]]; then echo "refusing reference hostname" >&2; exit 77; fi
if [[ -r "$build" ]]; then
  grep -q '^reference_vm=310$' "$build" && { echo "refusing reference_vm=310" >&2; exit 77; }
  grep -q '^template=reference-instance$' "$build" && { echo "refusing reference-instance" >&2; exit 77; }
fi
[[ -r "$marker" ]] || { echo "template candidate marker missing: $marker" >&2; exit 77; }
cat <<EOF
would sanitize template candidate $actual:
  evidence jobs logs scratch tmp tests/results
  credentials, Git credentials, external media fstab entries
  cloud-init state, machine-id, SSH host keys
  then shut down; host conversion remains: qm template 9310
EOF
$apply || exit 0
[[ $EUID -eq 0 ]] || { echo "--apply requires root" >&2; exit 77; }
find /srv/b70-encode/evidence /srv/b70-encode/logs /srv/b70-encode/scratch /srv/b70-encode/tmp /srv/b70-encode/tests/results -mindepth 1 -delete
for state in queued running succeeded failed; do find "/srv/b70-encode/jobs/$state" -mindepth 1 -delete; done
find /root /home -path '*/.git-credentials' -delete 2>/dev/null || true
find /root /home -path '*/.config/gh' -type d -prune -exec rm -rf -- {} + 2>/dev/null || true
find /root /home -path '*/.ssh' -type d -prune -exec rm -rf -- {} + 2>/dev/null || true
awk '$2 !~ "^/mnt/media/(source|work|output|archive)$"' /etc/fstab > /etc/fstab.b70-clean
install -m 0644 /etc/fstab.b70-clean /etc/fstab
rm -f /etc/fstab.b70-clean
cloud-init clean --logs --seed 2>/dev/null || true
truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id /etc/ssh/ssh_host_*_key /etc/ssh/ssh_host_*_key.pub
sync
echo "sanitization complete; shutting down and printing host-only conversion command: qm template 9310"
shutdown -h now
