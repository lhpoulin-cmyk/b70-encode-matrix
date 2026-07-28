#!/usr/bin/env bash
set -Eeuo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=profile-lib.sh
source "$script_dir/profile-lib.sh"
profile= apply=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile) profile=${2:?}; shift 2 ;;
    --dry-run) apply=false; shift ;;
    --apply) apply=true; shift ;;
    *) echo "usage: create-template.sh --profile FILE [--dry-run|--apply]" >&2; exit 64 ;;
  esac
done
[[ -r "$profile" ]] || { echo "profile required" >&2; exit 66; }
require_no_placeholders "$profile"
template_vmid=$(yaml_value "$profile" appliance template_vmid)
template_name=$(yaml_value "$profile" appliance template_name)
ubuntu_iso=$(yaml_value "$profile" appliance ubuntu_iso_volume)
cores=$(yaml_value "$profile" instance cores)
memory=$(yaml_value "$profile" instance memory_mb)
machine=$(yaml_value "$profile" virtualization machine)
bridge=$(yaml_value "$profile" virtualization bridge)
storage=$(yaml_value "$profile" storage os_storage)
disk_size=$(yaml_value "$profile" storage os_disk_size_gib)
[[ "$template_vmid" == 9310 ]] || { echo "this release packet expects template VMID 9310" >&2; exit 65; }
[[ "$template_name" == tpl-gpu-encode-ubuntu2604-* ]] || { echo "unexpected template name" >&2; exit 65; }
[[ "$cores" =~ ^[1-9][0-9]*$ && "$memory" =~ ^[1-9][0-9]*$ && "$disk_size" =~ ^(3[2-9]|[4-9][0-9])$ ]] || { echo "invalid CPU, memory, or 32-99 GiB disk size" >&2; exit 65; }
[[ "$machine" == q35 && -n "$bridge" && -n "$storage" && -n "$ubuntu_iso" ]] || { echo "missing or unsupported template virtualization/storage input" >&2; exit 65; }
commands=(
  "$(shell_join qm create "$template_vmid" --name "$template_name" --machine "$machine" --bios ovmf --cores "$cores" --memory "$memory" --scsihw virtio-scsi-single --net0 "virtio,bridge=$bridge" --serial0 socket --vga serial0 --ostype l26 --agent enabled=1)"
  "$(shell_join qm set "$template_vmid" --efidisk0 "$storage:1,efitype=4m,pre-enrolled-keys=1" --scsi0 "$storage:$disk_size,discard=on,ssd=1" --ide2 "$storage:cloudinit" --boot order=scsi0)"
  "$(shell_join qm set "$template_vmid" --ide0 "$ubuntu_iso,media=cdrom" --boot "order=ide0;scsi0")"
)
echo "# Candidate only: install/import Ubuntu 26.04, bootstrap, sanitize, shut down, then review: qm template $template_vmid"
printf '%s\n' "${commands[@]}"
$apply || exit 0
require_proxmox_host
qm status "$template_vmid" >/dev/null 2>&1 && { echo "VMID already exists: $template_vmid" >&2; exit 73; }
pvesm status --storage "$storage" >/dev/null || { echo "storage not found: $storage" >&2; exit 69; }
qm list | awk -v name="$template_name" 'NR>1 && $2 == name { found=1 } END { exit !found }' && { echo "template name already exists" >&2; exit 73; }
qm create "$template_vmid" --name "$template_name" --machine "$machine" --bios ovmf --cores "$cores" --memory "$memory" --scsihw virtio-scsi-single --net0 "virtio,bridge=$bridge" --serial0 socket --vga serial0 --ostype l26 --agent enabled=1
qm set "$template_vmid" --efidisk0 "$storage:1,efitype=4m,pre-enrolled-keys=1" --scsi0 "$storage:$disk_size,discard=on,ssd=1" --ide2 "$storage:cloudinit" --boot order=scsi0
qm set "$template_vmid" --ide0 "$ubuntu_iso,media=cdrom" --boot 'order=ide0;scsi0'
echo "candidate created; no GPU/raw disk attached and template conversion was not executed"
