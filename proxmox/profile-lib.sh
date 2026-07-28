#!/usr/bin/env bash

yaml_value() {
  local file=$1 section=$2 key=$3
  awk -v section="$section" -v key="$key" '
    $0 ~ "^" section ":[[:space:]]*$" { inside=1; next }
    inside && /^[^[:space:]#]/ { exit }
    inside && $0 ~ "^[[:space:]]+" key ":[[:space:]]*" {
      sub("^[[:space:]]+" key ":[[:space:]]*", "")
      gsub(/^"|"$/, "")
      print; exit
    }
  ' "$file"
}

require_no_placeholders() {
  local file=$1
  if grep -Eq '<[^>]+>' "$file"; then echo "profile contains unresolved placeholders: $file" >&2; return 65; fi
}

require_proxmox_host() {
  command -v qm >/dev/null || { echo "qm not found; run only on a Proxmox host" >&2; return 69; }
  if systemd-detect-virt --quiet 2>/dev/null; then
    echo "virtualized guest detected; refusing Proxmox host operation" >&2; return 77
  fi
  if [[ -r /srv/b70-encode/BUILD ]] && grep -q '^reference_vm=310$' /srv/b70-encode/BUILD; then
    echo "refusing host operation from reference VM 310" >&2; return 77
  fi
}

shell_join() { printf '%q ' "$@"; printf '\n'; }
