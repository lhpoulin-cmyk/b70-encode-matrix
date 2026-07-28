#!/usr/bin/env bash
set -Eeuo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=profile-lib.sh
source "$script_dir/profile-lib.sh"

vmid= mapping= slot=hostpci0 apply=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --vmid) vmid=${2:?}; shift 2 ;;
    --mapping) mapping=${2:?}; shift 2 ;;
    --slot) slot=${2:?}; shift 2 ;;
    --dry-run) apply=false; shift ;;
    --apply) apply=true; shift ;;
    *) echo "usage: attach-resource-mapping.sh --vmid ID --mapping NAME [--slot hostpciN] [--dry-run|--apply]" >&2; exit 64 ;;
  esac
done
[[ "$vmid" =~ ^[1-9][0-9]+$ && "$mapping" =~ ^[A-Za-z0-9._-]+$ && "$slot" =~ ^hostpci[0-9]+$ ]] || { echo "invalid VMID, mapping, or slot" >&2; exit 65; }
command=(qm set "$vmid" "--$slot" "mapping=$mapping,pcie=1")
printf '%q ' "${command[@]}"; echo
$apply || exit 0
require_proxmox_host
mapping_json=$(pvesh get /cluster/mapping/pci --output-format json)
grep -Eq "\"id\"[[:space:]]*:[[:space:]]*\"$mapping\"" <<< "$mapping_json" || { echo "resource mapping not found: $mapping" >&2; exit 69; }
"${command[@]}"
