#!/bin/sh
set -eu
expected_name='baoyan-world'
expected_email='340478108+baoyan-world@users.noreply.github.com'
expected_remote='git@github.com:baoyan-world/baoyan-handbook.git'
fail() { echo "publish identity check failed: $*" >&2; exit 1; }
[ "$(git config --local --get user.name || true)" = "$expected_name" ] || fail 'repository user.name must be baoyan-world'
[ "$(git config --local --get user.email || true)" = "$expected_email" ] || fail 'repository user.email must be baoyan-world noreply address'
[ "$(git config --local --get remote.origin.url || true)" = "$expected_remote" ] || fail 'origin must be baoyan-world/baoyan-handbook over SSH'
for ident in GIT_AUTHOR_IDENT GIT_COMMITTER_IDENT; do
  value=$(git var "$ident") || fail "cannot read $ident"
  case "$value" in
    "$expected_name <$expected_email> "*) ;;
    *) fail "$ident does not match baoyan-world" ;;
  esac
done
verify_ssh() {
  output=$(ssh -T -i "$HOME/.ssh/id_rsa" -o IdentitiesOnly=yes -o BatchMode=yes git@github.com 2>&1) || status=$?
  case "${output:-}" in
    *'Hi baoyan-world!'*'successfully authenticated'*) ;;
    *) fail 'GitHub SSH authentication is not baoyan-world' ;;
  esac
}
case "${1:-}" in
  '') ;;
  --push) verify_ssh ;;
  --release)
    verify_ssh
    command -v gh >/dev/null 2>&1 || fail 'GitHub CLI is required for guarded release publishing'
    gh_login=$(gh api user --jq .login 2>/dev/null || true)
    [ "$gh_login" = "$expected_name" ] || fail 'GitHub CLI authentication is not baoyan-world'
    ;;
  *) fail 'unknown option' ;;
esac
echo 'publish identity verified: baoyan-world'
