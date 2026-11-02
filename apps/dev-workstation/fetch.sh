#!/bin/sh
# Build-time helper, not shipped in the image.
#
#   fetch URL OUTPUT [CHECKSUM]
#
# Downloads URL to OUTPUT and fails on a checksum mismatch. CHECKSUM is either
# sha256:<hex>, or the URL of a checksum file: a bare hash, or "<hash>  <name>"
# lines looked up by the file name of URL. Omit it only when upstream publishes none.
set -eu

url=$1
output=$2
checksum=${3:-}

download() {
  curl -fsSL --retry 5 --retry-all-errors --connect-timeout 30 "$1" -o "$2"
}

download "$url" "$output"
chmod 755 "$output"

[ -n "$checksum" ] || exit 0

case "$checksum" in
  sha256:*)
    expected=${checksum#sha256:}
    ;;
  *)
    sums=$(mktemp)
    download "$checksum" "$sums"
    name=${url##*/}
    expected=$(awk -v name="$name" '{ file = $NF; sub(/^\*/, "", file); sub(/^.*\//, "", file); if (file == name) { print $1; exit } }' "$sums")
    if [ -z "$expected" ] && [ "$(wc -w < "$sums")" -eq 1 ]; then
      expected=$(cat "$sums")
    fi
    rm -f "$sums"
    ;;
esac

case "$expected" in
  *[!0-9a-f]* | "")
    echo "fetch: no sha256 for $url in $checksum" >&2
    exit 1
    ;;
esac
if [ "${#expected}" -ne 64 ]; then
  echo "fetch: no sha256 for $url in $checksum" >&2
  exit 1
fi

echo "$expected  $output" | sha256sum --check --quiet
