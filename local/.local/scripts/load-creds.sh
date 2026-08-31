#!/usr/bin/env bash

# =============================================================================
# load-creds.sh
#
# Sources the two things deliberately kept out of this repo:
#
#   hosts.env      internal hosts, endpoints, account names, ssh key paths.
#                  Symlink to the dotfiles-secrets repo, placed by bootstrap.sh.
#   cx-creds.env   the actual passwords. Restored from the secrets USB by
#                  dotfiles-secrets/copy-secrets.sh. Mode 600. Never in any repo.
#
# Both live in $SECRETS_DIR. This file names no host and no credential, so
# nothing in the dotfiles repo identifies anything.
#
# Usage:
#   source "${UTILSCRIPTS_DIR:-$HOME/.local/scripts}/load-creds.sh" || exit 1
#
# Returns 1 (or exits 1 if run rather than sourced) with both missing pieces
# listed at once, so a fresh machine sees the whole problem in one go.
# =============================================================================

SECRETS_DIR="${SECRETS_DIR:-$HOME/.local/share/secrets}"

_lc_missing=''
[ -r "$SECRETS_DIR/hosts.env" ] || _lc_missing="$_lc_missing  $SECRETS_DIR/hosts.env
      clone dotfiles-secrets, then: ~/dotfiles/bootstrap.sh --secrets <path-or-url>
"
[ -r "$SECRETS_DIR/cx-creds.env" ] || _lc_missing="$_lc_missing  $SECRETS_DIR/cx-creds.env
      restore from the secrets USB: dotfiles-secrets/copy-secrets.sh in <usb>
"

if [ -n "$_lc_missing" ]; then
    printf 'load-creds: missing\n%s' "$_lc_missing" >&2
    unset _lc_missing
    return 1 2>/dev/null || exit 1
fi
unset _lc_missing

source "$SECRETS_DIR/hosts.env"
source "$SECRETS_DIR/cx-creds.env"
