#!/bin/sh
set -eu
if [ "$#" -lt 1 ]; then
  echo 'usage: scripts/publish-release.sh vX.Y.Z [gh release create options...]' >&2
  exit 2
fi
version=$1
case "$version" in v[0-9]*.[0-9]*.[0-9]*) ;; *) echo 'version must look like v1.2.3' >&2; exit 2 ;; esac
shift
root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$root"
scripts/check-publish-identity.sh --release
if ! git show-ref --verify --quiet "refs/tags/$version"; then
  echo "tag $version must exist locally before release publishing" >&2; exit 1
fi
gh release create "$version" "$@"
