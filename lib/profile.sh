#!/usr/bin/env bash

profile_scalar() {
  local file=$1 section=$2 key=$3
  awk -v section="$section" -v key="$key" '
    $0 ~ "^" section ":[[:space:]]*$" { inside=1; next }
    inside && /^[^[:space:]#]/ { exit }
    inside && $0 ~ "^[[:space:]]+" key ":[[:space:]]*" {
      sub("^[[:space:]]+" key ":[[:space:]]*", "")
      gsub(/^"|"$/, "")
      print
      exit
    }
  ' "$file"
}

require_profile() {
  local file=$1
  [[ -r "$file" ]] || { echo "profile is not readable: $file" >&2; return 66; }
  local id version status
  id=$(profile_scalar "$file" profile id)
  version=$(profile_scalar "$file" profile version)
  status=$(profile_scalar "$file" profile status)
  [[ "$id" =~ ^[a-z0-9][a-z0-9-]*$ ]] || { echo "invalid or missing profile.id" >&2; return 65; }
  [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "invalid or missing profile.version" >&2; return 65; }
  [[ -n "$status" ]] || { echo "missing profile.status" >&2; return 65; }
  printf '%s\t%s\t%s\n' "$id" "$version" "$status"
}
