#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
addon_xml="$repo_root/addon.xml"

if [[ ! -f "$addon_xml" ]]; then
  echo "error: addon.xml not found at $addon_xml" >&2
  exit 1
fi

default_remote_host="root@192.168.1.128"

version="$(sed -n 's/.*<addon[^>]*version="\([^"]*\)".*/\1/p' "$addon_xml" | head -n 1)"
if [[ -z "$version" ]]; then
  echo "error: unable to determine add-on version from addon.xml" >&2
  exit 1
fi

addon_id="$(sed -n 's/.*<addon[^>]*id="\([^"]*\)".*/\1/p' "$addon_xml" | head -n 1)"
if [[ -z "$addon_id" ]]; then
  echo "error: unable to determine add-on id from addon.xml" >&2
  exit 1
fi

default_zip_remote_dir="/storage/downloads"
default_update_remote_dir="/storage/.kodi/addons/$addon_id"

usage() {
  cat >&2 <<EOF
usage:
  $0 zip [user@kodi-host] [remote-dir]
  $0 update [user@kodi-host] [remote-dir]
  $0 [user@kodi-host] [remote-dir]

examples:
  $0
  $0 zip $default_remote_host $default_zip_remote_dir
  $0 update $default_remote_host $default_update_remote_dir
EOF
}

mode="zip"
if [[ $# -gt 0 ]]; then
  case "$1" in
    zip|update)
      mode="$1"
      shift
      ;;
    -h|--help|help)
      usage
      exit 0
      ;;
  esac
fi

if [[ $# -gt 2 ]]; then
  usage
  exit 1
fi

remote_host="${1:-$default_remote_host}"
if [[ "$mode" == "update" ]]; then
  remote_dir="${2:-$default_update_remote_dir}"
else
  remote_dir="${2:-$default_zip_remote_dir}"
fi

dist_dir="$repo_root/dist"
zip_name="${addon_id}-${version}.zip"
zip_path="$dist_dir/$zip_name"

staging_root="$(mktemp -d)"
staging_dir="$staging_root/$addon_id"
cleanup() {
  rm -rf "$staging_root"
}
trap cleanup EXIT

mkdir -p "$staging_dir"
(
  cd "$repo_root"
  tar -cf - \
    --exclude='.git' \
    --exclude='dist' \
    --exclude='.DS_Store' \
    . | (cd "$staging_dir" && tar -xf -)
)

if [[ "$mode" == "zip" ]]; then
  mkdir -p "$dist_dir"
  rm -f "$zip_path"

  (
    cd "$staging_root"
    zip -qr "$zip_path" "$addon_id" \
      -x "$addon_id/.DS_Store" \
      -x "$addon_id/**/.DS_Store"
  )

  ssh "$remote_host" "mkdir -p '$remote_dir'"
  scp "$zip_path" "$remote_host:$remote_dir/"

  printf 'Copied %s to %s:%s/\n' "$zip_name" "$remote_host" "$remote_dir"
else
  ssh "$remote_host" "mkdir -p '$remote_dir'"
  (
    cd "$staging_dir"
    tar -cf - . | ssh "$remote_host" "cd '$remote_dir' && tar -xf -"
  )

  printf 'Updated %s on %s:%s/\n' "$addon_id" "$remote_host" "$remote_dir"
fi
