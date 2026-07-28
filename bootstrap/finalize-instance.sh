#!/usr/bin/env bash
set -Eeuo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
root=$(cd -- "$script_dir/.." && pwd)
release= commit= template= profile= deployment_profile= instance= created= representative= acceptance_record=
while [[ $# -gt 0 ]]; do
  case "$1" in
    --release) release=${2:?}; shift 2 ;;
    --commit) commit=${2:?}; shift 2 ;;
    --template) template=${2:?}; shift 2 ;;
    --profile) profile=${2:?}; shift 2 ;;
    --deployment-profile) deployment_profile=${2:?}; shift 2 ;;
    --instance) instance=${2:?}; shift 2 ;;
    --created-utc) created=${2:?}; shift 2 ;;
    --representative) representative=${2:?}; shift 2 ;;
    --acceptance-record) acceptance_record=${2:?}; shift 2 ;;
    *) echo "unknown argument: $1" >&2; exit 64 ;;
  esac
done
for item in release commit template profile deployment_profile instance representative acceptance_record; do [[ -n "${!item}" ]] || { echo "--${item//_/-} is required" >&2; exit 64; }; done
created=${created:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}
hostname_now=$(hostname -f)
[[ -f "$root/config/active-hardware-profile.yaml" ]] || { echo "active hardware profile missing" >&2; exit 69; }
render_node=$(awk '/^[[:space:]]+render_node:/ { print $2; exit }' "$root/config/active-hardware-profile.yaml")
gpu_observed=$(lspci -nn | awk '/VGA compatible controller|Display controller/ { print; exit }')
driver_observed=$(lspci -nnk | awk '/VGA compatible controller|Display controller/ { seen=1 } seen && /Kernel driver in use:/ { sub(/^.*Kernel driver in use:[[:space:]]*/, ""); print; exit }')
va_driver=$(vainfo --display drm --device "$render_node" 2>/dev/null | awk -F': ' '/Driver version:/ { print $2; exit }')
tmp_build=$(mktemp)
tmp_state=$(mktemp)
trap 'rm -f "$tmp_build" "$tmp_state"' EXIT
printf 'appliance=gpu-encode\nrelease=%s\ncommit=%s\ntemplate=%s\nprofile=%s\ndeployment_profile=%s\ninstance=%s\ncreated_utc=%s\n' "$release" "$commit" "$template" "$profile" "$deployment_profile" "$instance" "$created" > "$tmp_build"
"$root/tests/acceptance/appliance" --representative "$representative" --record "$acceptance_record"
{
  printf '# Current state\n\nGenerated from observation at `%s`.\n\n' "$created"
  printf -- '- Appliance: gpu-encode\n- Release: `%s`\n- Git commit: `%s`\n- Template: `%s`\n' "$release" "$commit" "$template"
  printf -- '- Hardware profile: `%s`\n- Deployment profile: `%s`\n- Instance: `%s`\n- Hostname: `%s`\n' "$profile" "$deployment_profile" "$instance" "$hostname_now"
  printf -- '- OS: `%s`\n- Kernel: `%s`\n- FFmpeg: `%s`\n' "$(. /etc/os-release; echo "$PRETTY_NAME")" "$(uname -r)" "$(ffmpeg -hide_banner -version | sed -n '1p')"
  printf -- '- GPU observed: `%s`\n- Kernel driver observed: `%s`\n- Render node: `%s`\n- VA driver observed: `%s`\n' "$gpu_observed" "$driver_observed" "$render_node" "$va_driver"
  echo
  echo 'Acceptance status: passed. See the retained acceptance record and `tests/results/`.'
} > "$tmp_state"
install -m 0664 "$tmp_build" "$root/BUILD"
install -m 0664 "$tmp_state" "$root/CURRENT_STATE.md"
echo "instance finalized; BUILD and CURRENT_STATE.md generated"
