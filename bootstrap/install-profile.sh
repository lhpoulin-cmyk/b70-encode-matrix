#!/usr/bin/env bash
set -Eeuo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
root=$(cd -- "$script_dir/.." && pwd)
# shellcheck source=../lib/profile.sh
source "$root/lib/profile.sh"
profile= render_node=
template_mode=false
dry_run=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile) profile=${2:?missing profile}; shift 2 ;;
    --render-node) render_node=${2:?missing render node}; shift 2 ;;
    --template-mode) template_mode=true; shift ;;
    --dry-run) dry_run=true; shift ;;
    *) echo "usage: install-profile.sh --profile FILE [--render-node PATH] [--template-mode] [--dry-run]" >&2; exit 64 ;;
  esac
done
[[ -n "$profile" ]] || { echo "--profile is required" >&2; exit 64; }
IFS=$'\t' read -r id version status < <(require_profile "$profile")
case "$status" in
  operational) ;;
  template-only) $template_mode || { echo "template-only profile requires --template-mode" >&2; exit 69; } ;;
  *) echo "refusing unsupported profile '$id' with status '$status'" >&2; exit 69 ;;
esac
if [[ -n "$render_node" && "$render_node" != /dev/dri/renderD* ]]; then echo "render-node override must be a /dev/dri/renderD* path" >&2; exit 65; fi
commit=$(git -C "$root" rev-parse HEAD 2>/dev/null || echo unavailable)
destination="$root/config/active-hardware-profile.yaml"
if $dry_run; then
  echo "would install profile=$id version=$version status=$status render_override=${render_node:-none} commit=$commit"
  exit 0
fi
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
cp "$profile" "$tmp"
{
  printf '\ninstallation:\n  installed_utc: "%s"\n  source_commit: "%s"\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$commit"
  [[ -n "$render_node" ]] && printf 'deployment_overrides:\n  render_node: "%s"\n' "$render_node"
} >> "$tmp"
install -m 0664 "$tmp" "$destination"
if getent group media-pipeline >/dev/null; then chgrp media-pipeline "$destination"; fi
echo "installed $id $version at $destination"
