#!/usr/bin/env bash
# Bring a machine up to this configuration. Idempotent; safe to re-run.
#
#   ./bootstrap.sh
#   ./bootstrap.sh --secrets ~/dotfiles-secrets
#   ./bootstrap.sh --secrets git@github.com:<you>/dotfiles-secrets.git
#
# The companion dotfiles-secrets repo holds every internal identifier (hosts,
# endpoints, account names, the secrets manifest). This repo names none of them.
# Resolution order for it: --secrets, then $DOTFILES_SECRETS, then
# ~/dotfiles-secrets, then a dotfiles-secrets/ sibling of this repo. Missing is
# not fatal: everything else still installs, only the cx-* scripts stay inert.
set -euo pipefail

DOTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST="$(hostnamectl hostname 2>/dev/null || cat /etc/hostname)"
SECRETS_DIR="${SECRETS_DIR:-$HOME/.local/share/secrets}"
SECRETS_SRC="${DOTFILES_SECRETS:-}"

while [ $# -gt 0 ]; do
    case "$1" in
        --secrets) SECRETS_SRC="${2:?--secrets needs a path or git URL}"; shift 2 ;;
        -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
        *) echo "unknown argument: $1" >&2; exit 1 ;;
    esac
done

command -v stow >/dev/null || { echo "stow not installed: sudo pacman -S stow" >&2; exit 1; }

# ---------------------------------------------------------------------------
# 1. symlink the packages into $HOME
#
# --no-folding symlinks individual FILES rather than whole directories, so
# omarchy / hyprshade / theme-switching can keep writing their own files into
# ~/.config/hypr and ~/.config/omarchy.
#
# stow refuses to clobber a real file, so pre-existing ones must be cleared
# first. Two passes: detect every conflict before touching anything, then act.
# Only files byte-identical to the repo copy are removed. This is deliberately
# NOT `stow --adopt`, which would silently pull the live version into the repo
# -- and with it any secret the repo copy had scrubbed out.
# ---------------------------------------------------------------------------
list_files() { ( cd "$DOTS/$1" && find . -type f -printf '%P\n' ); }

echo "==> checking for conflicts"
conflicts=""
identical=""
for pkg in home local config; do
    while read -r rel; do
        live="$HOME/$rel"
        [ -e "$live" ] || continue
        [ -L "$live" ] && continue                        # already stowed
        if cmp -s "$DOTS/$pkg/$rel" "$live"; then
            identical="$identical$live"$'\n'
        else
            conflicts="$conflicts    ~/$rel  differs from  $pkg/$rel"$'\n'
        fi
    done < <(list_files "$pkg")
done

if [ -n "$conflicts" ]; then
    printf '%s' "$conflicts"
    cat >&2 <<'MSG'

aborting: nothing has been changed. Reconcile each file above, then re-run.
  keep the live version -> copy it into the repo (check it for secrets first)
  keep the repo version -> delete the live file
MSG
    exit 1
fi

if [ -n "$identical" ]; then
    echo "==> clearing $(printf '%s' "$identical" | grep -c . ) identical live files so stow can link them"
    printf '%s' "$identical" | while read -r f; do [ -n "$f" ] && rm -f "$f"; done
fi

echo "==> stowing"
stow --no-folding -v -d "$DOTS" -t "$HOME" home local config

# ---------------------------------------------------------------------------
# 2. per-host monitor layout
# ---------------------------------------------------------------------------
MON_SRC="$DOTS/config/.config/hypr/monitors.d/$HOST.conf"
MON_DST="$HOME/.config/hypr/monitors.conf"
if [ -f "$MON_SRC" ]; then
    echo "==> monitors: linking $HOST.conf"
    ln -sfn "$MON_SRC" "$MON_DST"
else
    echo "==> monitors: no layout for '$HOST', writing autodetect stub"
    rm -f "$MON_DST"
    cat > "$MON_DST" <<'EOF'
# No per-host layout for this machine yet.
# Configure with hyprmon, then save the result to
# ~/dotfiles/config/.config/hypr/monitors.d/<hostname>.conf and re-run bootstrap.sh
monitor=,preferred,auto,1
EOF
fi

# ---------------------------------------------------------------------------
# 3. wallpaper (lives outside .config, referenced by omarchy/current/background)
# ---------------------------------------------------------------------------
if [ ! -f "$HOME/.dragonflight.jpeg" ]; then
    echo "==> wallpaper"
    cp "$DOTS/assets/dragonflight.jpeg" "$HOME/.dragonflight.jpeg"
fi
mkdir -p "$HOME/.config/omarchy/current"
ln -sfn "$HOME/.dragonflight.jpeg" "$HOME/.config/omarchy/current/background"

# ---------------------------------------------------------------------------
# 4. omarchy theme (hard copy, not stowed)
#
# themes/harbordark is a byte-for-byte copy of the live
# ~/.config/omarchy/current/theme -- the user theme, the tweaks made on top of
# it, and the files omarchy-theme-set-templates generates. It is copied rather
# than stowed because omarchy-theme-set does `rm -rf current/theme` on every
# theme switch: symlinks there would be deleted, and writes meant for the live
# tree would land back in this repo.
#
# themes/<name>/ is the durable half (what omarchy-theme-set reads), so the copy
# goes there too. current/theme is only seeded when absent, to avoid stomping a
# live theme on re-runs.
# ---------------------------------------------------------------------------
THEME_NAME="$(cat "$DOTS/config/.config/omarchy/current/theme.name" 2>/dev/null || echo harbordark)"
THEME_SRC="$DOTS/themes/$THEME_NAME"
if [ -d "$THEME_SRC" ]; then
    echo "==> omarchy theme: $THEME_NAME"
    mkdir -p "$HOME/.config/omarchy/themes/$THEME_NAME"
    cp -a "$THEME_SRC/." "$HOME/.config/omarchy/themes/$THEME_NAME/"
    if [ ! -e "$HOME/.config/omarchy/current/theme" ]; then
        echo "    seeding current/theme (run: omarchy-theme-set $THEME_NAME to regenerate)"
        mkdir -p "$HOME/.config/omarchy/current/theme"
        cp -a "$THEME_SRC/." "$HOME/.config/omarchy/current/theme/"
    fi
else
    echo "==> omarchy theme: themes/$THEME_NAME missing from repo, skipping"
fi

# ---------------------------------------------------------------------------
# 5. systemd user units
# ---------------------------------------------------------------------------
echo "==> systemd user units"
systemctl --user daemon-reload
while read -r unit; do
    [ -z "$unit" ] && continue
    systemctl --user enable "$unit" 2>/dev/null || echo "    skip (not installed): $unit"
done < "$DOTS/packages/systemd-user-enabled.txt"

# ---------------------------------------------------------------------------
# 6. dotfiles-secrets: clone if needed, then link hosts.env into $SECRETS_DIR
#
# Linked, not copied. `rm -rf .git && cp -r` would fork the identifiers into an
# untracked second copy that silently rots; a symlink means `git pull` in the
# secrets repo is immediately live everywhere.
# ---------------------------------------------------------------------------
SECRETS_REPO=""
case "$SECRETS_SRC" in
    "")  for cand in "$HOME/dotfiles-secrets" "$(dirname "$DOTS")/dotfiles-secrets"; do
             [ -d "$cand" ] && { SECRETS_REPO="$cand"; break; }
         done ;;
    *://*|*@*:*)
         SECRETS_REPO="$HOME/dotfiles-secrets"
         if [ -d "$SECRETS_REPO/.git" ]; then
             echo "==> secrets: $SECRETS_REPO already cloned"
         else
             echo "==> secrets: cloning into $SECRETS_REPO"
             git clone --depth 1 "$SECRETS_SRC" "$SECRETS_REPO"
         fi ;;
    *)   SECRETS_REPO="$(cd "$SECRETS_SRC" 2>/dev/null && pwd)" \
             || { echo "==> secrets: no such path: $SECRETS_SRC" >&2; SECRETS_REPO=""; } ;;
esac

mkdir -p "$SECRETS_DIR"; chmod 700 "$SECRETS_DIR"

if [ -n "$SECRETS_REPO" ] && [ -f "$SECRETS_REPO/env/hosts.env" ]; then
    echo "==> secrets: linking hosts.env from $SECRETS_REPO"
    ln -sfn "$SECRETS_REPO/env/hosts.env" "$SECRETS_DIR/hosts.env"
    chmod 600 "$SECRETS_DIR/cx-creds.env" 2>/dev/null || true
else
    echo "==> secrets: dotfiles-secrets not found, skipping"
    echo "    the cx-rdp-*/ssh237/cx-vpn scripts and init-ssh.sh will exit 1 until it is"
    echo "    re-run: ./bootstrap.sh --secrets <path-or-git-url>"
fi

# ---------------------------------------------------------------------------
# 7. things this script deliberately cannot do
# ---------------------------------------------------------------------------
echo
echo "remaining manual steps:"
[ -r "$SECRETS_DIR/hosts.env" ] \
    || echo "  - clone dotfiles-secrets, then: ./bootstrap.sh --secrets <path-or-url>"
[ -r "$SECRETS_DIR/cx-creds.env" ] \
    || echo "  - restore passwords from the USB: dotfiles-secrets/copy-secrets.sh in <usb>"
command -v walker >/dev/null && [ "$(command -v walker)" = /usr/local/bin/walker ] \
    || echo "  - build custom walker (see README step 3) - fuzzy-match highlighting is missing without it"
[ -d "$HOME/.config/omarchy/themes/$THEME_NAME" ] \
    || echo "  - reinstall the $THEME_NAME theme (omarchy-theme-install); other themes are not in this repo"
echo "  - hyprctl reload"
