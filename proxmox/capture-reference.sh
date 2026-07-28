#!/usr/bin/env bash
set -Eeuo pipefail

destination=${1:-/srv/b70-encode/evidence/$(date -u +%Y%m%dT%H%M%SZ)-reference-capture}
mkdir -p "$destination"
hostnamectl > "$destination/hostname.txt" 2>&1 || true
cat /etc/os-release > "$destination/os-release.txt"
uname -a > "$destination/kernel.txt"
lspci -nnk > "$destination/pci.txt"
ls -la /dev/dri > "$destination/dri.txt" 2>&1 || true
ffmpeg -hide_banner -version > "$destination/ffmpeg.txt" 2>&1 || true
dpkg-query -W ffmpeg libvpl2 libmfx-gen1.2 intel-media-va-driver-non-free vainfo > "$destination/packages.txt" 2>&1 || true
echo "$destination"
