#!/bin/bash

set -euo pipefail

su

print_help() {
  echo "usage: $0 [group]..."
  echo
  echo "  available groups: "${!GROUPED_DEPS[@]}""
}

declare -rA GROUPED_DEPS=(
  # Common dependencies for building OpenMW.
  [openmw-deps]="
    libluajit-5.1-dev
  "
)

if [[ $# -eq 0 ]]; then
  >&2 print_help
  exit 1
fi

deps=()
for group in "$@"; do
  if [[ ! -v GROUPED_DEPS[$group] ]]; then
    >&2 echo "error: unknown group ${group}"
    exit 1
  fi
  deps+=(${GROUPED_DEPS[$group]})
done

export APT_CACHE_DIR="${PWD}/apt-cache"
set -x
mkdir -pv "$APT_CACHE_DIR"
apt-get update -yq
apt-get -q -o dir::cache::archives="$APT_CACHE_DIR" install -y --no-install-recommends "${deps[@]}"
