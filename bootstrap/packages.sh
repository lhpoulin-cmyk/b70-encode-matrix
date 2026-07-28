#!/usr/bin/env bash
set -Eeuo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
root=$(cd -- "$script_dir/.." && pwd)
# shellcheck source=../lib/profile.sh
source "$root/lib/profile.sh"
profile=
apply=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile) profile=${2:?missing profile}; shift 2 ;;
    --apply) apply=true; shift ;;
    --dry-run) apply=false; shift ;;
    *) echo "usage: packages.sh --profile FILE [--dry-run|--apply]" >&2; exit 64 ;;
  esac
done
[[ -n "$profile" ]] || { echo "--profile is required" >&2; exit 64; }
IFS=$'\t' read -r profile_id _ status < <(require_profile "$profile")
case "$status" in operational|template-only) ;; *) echo "unsupported profile status: $status" >&2; exit 69 ;; esac
packages=(ffmpeg pciutils vainfo)
case "$profile_id" in
  generic) ;;
  intel-battlemage) packages+=(libvpl2 libvpl-tools libmfx-gen1.2 intel-media-va-driver-non-free) ;;
  *) echo "no package set for profile: $profile_id" >&2; exit 69 ;;
esac
echo "Proposed Ubuntu package transaction (no upgrade/autoremove):"
printf '  %s\n' "${packages[@]}"
apt-get -s install --no-install-recommends "${packages[@]}"
$apply || { echo "dry-run complete; pass --apply as root to install"; exit 0; }
[[ $EUID -eq 0 ]] || { echo "--apply requires root" >&2; exit 77; }
apt-get install --no-install-recommends "${packages[@]}"
mkdir -p /var/lib/b70-encode
dpkg-query -W "${packages[@]}" > /var/lib/b70-encode/package-versions.txt
