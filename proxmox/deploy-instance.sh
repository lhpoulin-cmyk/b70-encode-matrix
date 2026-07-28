#!/usr/bin/env bash
set -Eeuo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=profile-lib.sh
source "$script_dir/profile-lib.sh"
profile= apply=false no_start=false skip_gpu=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile) profile=${2:?}; shift 2 ;;
    --dry-run) apply=false; shift ;;
    --apply) apply=true; shift ;;
    --no-start) no_start=true; shift ;;
    --skip-gpu) skip_gpu=true; shift ;;
    *) echo "usage: deploy-instance.sh --profile FILE [--dry-run|--apply] [--no-start] [--skip-gpu]" >&2; exit 64 ;;
  esac
done
[[ -r "$profile" ]] || { echo "profile required" >&2; exit 66; }
require_no_placeholders "$profile"
template=$(yaml_value "$profile" appliance template_vmid)
release=$(yaml_value "$profile" appliance release)
repository=$(yaml_value "$profile" appliance repository)
vmid=$(yaml_value "$profile" instance vmid)
name=$(yaml_value "$profile" instance name)
node=$(yaml_value "$profile" instance node)
cores=$(yaml_value "$profile" instance cores)
memory=$(yaml_value "$profile" instance memory_mb)
bridge=$(yaml_value "$profile" virtualization bridge)
mapping=$(yaml_value "$profile" gpu resource_mapping)
hardware_profile=$(yaml_value "$profile" gpu profile)
render_node=$(yaml_value "$profile" gpu render_node)
storage=$(yaml_value "$profile" storage os_storage)
scratch=$(yaml_value "$profile" storage scratch_assignment)
user_data=$(yaml_value "$profile" cloud_init user_data)
vendor_data=$(yaml_value "$profile" cloud_init vendor_data)
network_config=$(yaml_value "$profile" cloud_init network_config)
snippets_storage=$(yaml_value "$profile" cloud_init snippets_storage)
snippets_directory=$(yaml_value "$profile" cloud_init snippets_directory)
[[ "$template" =~ ^[1-9][0-9]+$ && "$vmid" =~ ^[1-9][0-9]+$ && "$template" != "$vmid" ]] || { echo "invalid template/target VMID" >&2; exit 65; }
[[ "$name" =~ ^[A-Za-z0-9][A-Za-z0-9._-]+$ ]] || { echo "invalid target name" >&2; exit 65; }
[[ "$cores" =~ ^[1-9][0-9]*$ && "$memory" =~ ^[1-9][0-9]*$ ]] || { echo "invalid CPU or memory" >&2; exit 65; }
[[ -n "$node" && -n "$bridge" && -n "$storage" && -n "$hardware_profile" && "$render_node" == /dev/dri/renderD* ]] || { echo "missing deployment identity, storage, profile, or render node" >&2; exit 65; }
if ! $skip_gpu; then [[ "$mapping" =~ ^[A-Za-z0-9._-]+$ ]] || { echo "invalid resource mapping" >&2; exit 65; }; fi
for file in "$user_data" "$vendor_data" "$network_config"; do [[ -r "$file" ]] || { echo "cloud-init input missing: $file" >&2; exit 66; }; done
commands=(
  "$(shell_join qm clone "$template" "$vmid" --name "$name" --full 1 --target "$node" --storage "$storage")"
  "$(shell_join qm set "$vmid" --cores "$cores" --memory "$memory" --net0 "virtio,bridge=$bridge")"
  "$(shell_join install -m 0600 "$user_data" "$snippets_directory/$vmid-user.yaml")"
  "$(shell_join install -m 0600 "$vendor_data" "$snippets_directory/$vmid-vendor.yaml")"
  "$(shell_join install -m 0600 "$network_config" "$snippets_directory/$vmid-network.yaml")"
  "$(shell_join qm set "$vmid" --cicustom "user=$snippets_storage:snippets/$vmid-user.yaml,vendor=$snippets_storage:snippets/$vmid-vendor.yaml,network=$snippets_storage:snippets/$vmid-network.yaml")"
)
if ! $skip_gpu; then commands+=("$(shell_join "$script_dir/attach-resource-mapping.sh" --vmid "$vmid" --mapping "$mapping" --apply)"); fi
if [[ -n "$scratch" && "$scratch" != none ]]; then commands+=("$(shell_join qm set "$vmid" --scsi1 "$scratch")"); fi
$no_start || commands+=("$(shell_join qm start "$vmid")")
printf '# repository=%s release=%s hardware_profile=%s render_node=%s\n' "$repository" "$release" "$hardware_profile" "$render_node"
printf '%s\n' "${commands[@]}"
echo "# after boot/GPU attachment: install hardware profile, reboot if required, finalize, and run acceptance"
$apply || exit 0
require_proxmox_host
[[ -d "$snippets_directory" ]] || { echo "snippets directory not found: $snippets_directory" >&2; exit 69; }
pvesm status --storage "$snippets_storage" >/dev/null || { echo "snippets storage not found: $snippets_storage" >&2; exit 69; }
pvesh get "/nodes/$node/status" >/dev/null || { echo "target node not found: $node" >&2; exit 69; }
template_config=$(qm config "$template")
grep -Fx 'template: 1' <<< "$template_config" >/dev/null || { echo "clone source is not a template" >&2; exit 69; }
qm status "$vmid" >/dev/null 2>&1 && { echo "target VMID already used" >&2; exit 73; }
qm list | awk -v name="$name" 'NR>1 && $2 == name { found=1 } END { exit !found }' && { echo "target name already used" >&2; exit 73; }
pvesm status --storage "$storage" >/dev/null || { echo "storage not found: $storage" >&2; exit 69; }
if ! $skip_gpu; then
  mapping_json=$(pvesh get /cluster/mapping/pci --output-format json)
  grep -Eq "\"id\"[[:space:]]*:[[:space:]]*\"$mapping\"" <<< "$mapping_json" || { echo "mapping not found: $mapping" >&2; exit 69; }
  grep -Rqs "mapping=$mapping" /etc/pve/qemu-server && { echo "exclusive mapping appears assigned; inspect before deployment" >&2; exit 73; }
fi
qm clone "$template" "$vmid" --name "$name" --full 1 --target "$node" --storage "$storage"
qm set "$vmid" --cores "$cores" --memory "$memory" --net0 "virtio,bridge=$bridge"
install -m 0600 "$user_data" "$snippets_directory/$vmid-user.yaml"
install -m 0600 "$vendor_data" "$snippets_directory/$vmid-vendor.yaml"
install -m 0600 "$network_config" "$snippets_directory/$vmid-network.yaml"
qm set "$vmid" --cicustom "user=$snippets_storage:snippets/$vmid-user.yaml,vendor=$snippets_storage:snippets/$vmid-vendor.yaml,network=$snippets_storage:snippets/$vmid-network.yaml"
if ! $skip_gpu; then "$script_dir/attach-resource-mapping.sh" --vmid "$vmid" --mapping "$mapping" --apply; fi
if [[ -n "$scratch" && "$scratch" != none ]]; then qm set "$vmid" --scsi1 "$scratch"; fi
$no_start || qm start "$vmid"
echo "clone configured; cloud-init snippet upload and guest acceptance remain explicit operator gates"
