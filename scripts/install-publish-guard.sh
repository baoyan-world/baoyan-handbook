#!/bin/sh
set -eu
root=$(git rev-parse --show-toplevel)
cd "$root"
expected='git@github.com:baoyan-world/baoyan-handbook.git'
[ "$(git config --local --get remote.origin.url || true)" = "$expected" ] || {
  echo 'refusing to install outside baoyan-world/baoyan-handbook' >&2; exit 1;
}
key=${GITHUB_SSH_KEY:-$HOME/.ssh/id_rsa}
[ -r "$key" ] || { echo 'baoyan-world SSH key is unavailable' >&2; exit 1; }
git config --local user.name baoyan-world
git config --local user.email 340478108+baoyan-world@users.noreply.github.com
git config --local core.hooksPath .githooks
git config --local core.sshCommand "ssh -i $key -o IdentitiesOnly=yes"
scripts/check-publish-identity.sh --push
echo 'repository-local baoyan-world identity and hooks installed'
