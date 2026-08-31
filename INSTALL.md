# dotfiles

Omarchy / Hyprland configuration for `lap-jup-okom`, managed with GNU stow.

Two repos, split by what they reveal:

| Repo                      | Holds                                                                                                             | Exposure                                                                                                                                                       |
| ------------------------- | ----------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`dotfiles`** (this one) | configuration and scripts                                                                                         | names no host, endpoint, account or secret path. Only identifying content is the work email in `.gitconfig`, which every commit's author field carries anyway. |
| **`dotfiles-secrets`**    | every _identifier_ — internal hosts, VPN endpoint, account names, ssh key paths, and the 41-path secrets manifest | keep private. Identifiers only, still no passwords.                                                                                                            |
| the secrets **USB**       | the actual credential values                                                                                      | never in any repo.                                                                                                                                             |

So this repo can be shared without mapping out your infrastructure; see "Secrets".

## Layout

| Path                            | What                                                                                                                                |
| ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `home/`                         | stow package → `$HOME` dotfiles (`.zshrc`, `.bashrc`, `.gitconfig`)                                                                 |
| `local/`                        | stow package → `~/.local/{bin,scripts}`                                                                                             |
| `config/`                       | stow package → `~/.config` (whitelisted; ~1.6MB of actual config)                                                                   |
| `assets/`                       | `dragonflight.jpeg` — the wallpaper, lives outside `.config`                                                                        |
| `themes/`                       | hard copy of the live omarchy theme (`harbordark`, 19MB). Copied, not stowed — see "Theme"                                          |
| `patches/`                      | uncommitted upstream modifications that would otherwise be lost                                                                     |
| `packages/`                     | `pacman -Qqen` / `-Qqem` lists, enabled systemd user units, and `build-provenance.txt`                                              |
| `packages/record-provenance.sh` | regenerates `build-provenance.txt`: the exact commit every locally-built repo sits on                                               |
| `bootstrap.sh`                  | stow + per-host monitors + systemd enable + link the secrets repo. Idempotent; refuses to run if a live file differs from the repo. |

`secrets-manifest.txt` and `copy-secrets.sh` used to live here. They moved to
`dotfiles-secrets` — a list of exactly which paths hold your credentials is itself
worth not publishing.

## Quickstart

Copy-paste, one line at a time. Each is idempotent; re-running is safe.

**Already on Omarchy, just want the config** (steps 1, 2, 8):

```bash
# 1. prerequisites
sudo pacman -S --needed git stow base-devel rust

# 2. clone + install everything this repo can install by itself
git clone git@github.com:komadiina/dotfiles.git ~/dotfiles && ~/dotfiles/bootstrap.sh

# 3. every explicitly-installed package, repo then AUR
sudo pacman -S --needed - < ~/dotfiles/packages/pacman-explicit.txt && yay -S --needed - < ~/dotfiles/packages/aur-foreign.txt

# 4. reapply the local omarchy modifications (dry-run first: swap `apply` for `apply --check`)
git -C ~/.local/share/omarchy apply ~/dotfiles/patches/omarchy-local-mods.patch

# 5. custom walker, fork route - fuzzy-match highlighting
git clone -b highlight-matches git@github.com:komadiina/walker.git ~/repos/walker && cargo build --release --manifest-path ~/repos/walker/Cargo.toml && sudo ln -sfn ~/repos/walker/target/release/walker /usr/local/bin/walker

# 6. (optional) link the secrets repo (identifiers; clones it if given a URL)
~/dotfiles/bootstrap.sh --secrets git@github.com:komadiina/dotfiles-secrets.git

# 7. (optional) credential values, off the USB
~/dotfiles-secrets/copy-secrets.sh in /run/media/$USER/<label>

# 8. apply
omarchy-theme-set harbordark && hyprctl reload
```

Step 2 aborts and lists every file that differs from the repo rather than
overwriting either side, so run it before the rest and reconcile what it names.
Steps 6 and 7 are optional — omit them and everything still installs; only the
`cx-*` scripts stay inert. `bootstrap.sh` prints whatever is still missing at the
end, so re-read its last few lines instead of tracking this list by hand.

Fuller explanation of each step, and the fallbacks when a remote is gone, below.

## Rebuild a machine

```bash
# 1. base system
sudo pacman -S --needed - < packages/pacman-explicit.txt
yay -S --needed - < packages/aur-foreign.txt        # includes mpvpaper
sudo pacman -S --needed stow rust elephant hyprlock hyprshade

# 2. omarchy, then reapply local mods
#    (install omarchy per upstream first)
git -C ~/.local/share/omarchy apply ~/dotfiles/patches/omarchy-local-mods.patch
#    these apply onto patches/omarchy-base-commit; see "Applying the patches"

# 3. custom walker  (fuzzy-match highlighting - see "Custom builds")
git clone git@github.com:komadiina/walker.git ~/repos/walker   # fork; carries the patch
cd ~/repos/walker && git checkout highlight-matches
#    upstream-only fallback, if the fork is gone:
#      git clone https://github.com/abenz1267/walker ~/repos/walker
#      git checkout "$(cat ~/dotfiles/patches/walker-base-commit)"
#      git apply ~/dotfiles/patches/walker-highlight-matches.patch
cargo build --release
sudo ln -sfn ~/repos/walker/target/release/walker /usr/local/bin/walker

# 4. dotfiles + dotfiles-secrets
git clone <dotfiles-remote> ~/dotfiles
~/dotfiles/bootstrap.sh --secrets <dotfiles-secrets-remote>
#    clones dotfiles-secrets to ~/dotfiles-secrets and links its hosts.env into
#    ~/.local/share/secrets/. Omit --secrets and everything still installs; only
#    the cx-* scripts stay inert until you supply it.
#    On a machine that already has config in place, bootstrap.sh aborts and lists
#    any file that differs from the repo rather than overwriting either side.

# 5. credential values, off the USB
~/dotfiles-secrets/copy-secrets.sh in /run/media/$USER/<label>

# 6. themes
#    the active one (harbordark) is in this repo under themes/ and bootstrap.sh
#    already copied it into place. Any *other* theme is its own git clone, 662MB:
omarchy-theme-install <url>

hyprctl reload
```

## Custom builds

**walker** is the only source-patched program. Upstream `v2.17.0` (`42b3ed88`) plus
`patches/walker-highlight-matches.patch`: a `highlight_matches()` that Pango-marks
fuzzy-matched characters in item labels, using the same
`MatcherConfig::DEFAULT.match_paths()` as `sort_items_fuzzy` in `data.rs`. Colour comes
from the theme's `@match`, falling back to `@selected-text`, then bold+underline.
Enable it by uncommenting `@define-color match` in
`config/.config/walker/themes/omarchy-transparent/style.css`.

The packaged `walker` (omarchy repo) owns `/usr/bin/walker`; the custom build is
symlinked at `/usr/local/bin/walker`. **`/usr/local/bin` must come before `/usr/bin`
in `PATH`** or you silently get the unpatched one.

**mpvpaper** and **hyprlock** are _not_ custom builds — stock AUR `1.9-1` and stock Arch
`extra 0.9.6-2`. All the behaviour is config plus two wrappers.

`packages/build-provenance.txt` records the exact commit, branch, upstream tracking
state and toolchain version for every locally-built or locally-modified repo (walker,
omarchy, Hyprlain), so a rebuild lands on the same source instead of whatever upstream
HEAD happens to be. **Regenerate it after any build, checkout or pull:**

```bash
~/dotfiles/packages/record-provenance.sh
```

## Applying the patches

Both files in `patches/` are plain `git diff` output, **not** `git format-patch`
mailboxes. So they go on with `git apply`, never `git am` — `git am` fails with
"Patch format detection failed". They also carry `i/`…`w/` path prefixes rather
than `a/`…`b/` (this machine has `diff.mnemonicPrefix` set); `git apply` strips one
level either way, so that makes no difference.

```bash
# check before committing to it - prints nothing and exits 0 if it will apply
git -C <repo> apply --check patches/<name>.patch
git -C <repo> apply         patches/<name>.patch
```

Each patch has a `*-base-commit` file beside it naming the commit it was cut
against. Check that out first and the patch applies exactly:

| Patch                            | Repo                     | Base commit                                       |
| -------------------------------- | ------------------------ | ------------------------------------------------- |
| `walker-highlight-matches.patch` | `~/repos/walker`         | `patches/walker-base-commit` (upstream `v2.17.0`) |
| `omarchy-local-mods.patch`       | `~/.local/share/omarchy` | `patches/omarchy-base-commit` (branch `dev`)      |

**If upstream has moved on** and the patch no longer applies, use a three-way
merge instead of hand-editing. It needs the blob hashes in the patch header, which
is why the patch must be applied inside a clone of the same upstream repo:

```bash
git -C <repo> apply -3 patches/<name>.patch   # leaves conflict markers to resolve
```

**Refresh a patch after changing either tree** — the patch file is the only copy of
the omarchy modifications, so this is not optional maintenance:

```bash
git -C ~/.local/share/omarchy diff > ~/dotfiles/patches/omarchy-local-mods.patch
git -C ~/.local/share/omarchy rev-parse HEAD > ~/dotfiles/patches/omarchy-base-commit
```

### walker specifically

The walker patch has a second, better route: it is also commit `89ef0c7` on the
local branch `highlight-matches` in `~/repos/walker`. Push that branch to your own
fork and the new machine skips patching entirely:

```bash
git clone https://github.com/abenz1267/walker ~/repos/walker
cd ~/repos/walker
git remote add fork git@github.com:<you>/walker.git
git fetch fork && git checkout highlight-matches
cargo build --release
```

Verified: applying the patch onto the base commit produces a byte-identical
`src/renderers/mod.rs` to what the branch commit holds. Either route is correct;
the branch survives a lost USB and a lost dotfiles repo, the patch does not.

## Theme

`themes/harbordark/` is a byte-for-byte copy of the live
`~/.config/omarchy/current/theme/` — 19MB, of which 16MB is `backgrounds/` and 2.5MB
the `preview*.png`. It holds three things at once:

- the user theme as `omarchy-theme-install` cloned it,
- the files `omarchy-theme-set-templates` generates on each switch (`alacritty.toml`,
  `ghostty.conf`, `kitty.conf`, `keyboard.rgb`, `obsidian.css`,
  `hyprland-preview-share-picker.css`),
- local edits made directly in `current/theme` — `walker.css` and `waybar.css` here
  differ from the `themes/harbordark/` clone they came from.

That last point is why the copy is worth having: `omarchy-theme-set` does
`rm -rf current/theme` and rebuilds it from `~/.config/omarchy/themes/<name>` + the
templates, so anything edited only in `current/theme` is one theme switch away from
gone.

Bootstrap step 4 copies it to `~/.config/omarchy/themes/harbordark/` — the durable
half, where `omarchy-theme-set` reads from, so the local edits now survive a switch —
and seeds `current/theme/` only if that path does not already exist. It is a `cp -a`,
not a stow link: stow links under `current/theme` would be deleted by the next
`rm -rf`, and writes aimed at the live tree would land back in this repo.

To re-capture after further tweaking:

```bash
cp -a ~/.config/omarchy/current/theme/. ~/dotfiles/themes/harbordark/
```

## Shader wallpaper & lockscreen

- `~/.local/bin/shader-wallpaper` replaces swaybg: runs `mpvpaper` with
  `glsl-shaders=~/.config/omarchy/shaders/wallpaper.glsl` over a looped still.
- `wallpaper.glsl` converts `frame/30.0` to seconds and the launcher pins `fps=30`.
  **Change one, change the other** or the animation speed drifts.
- `~/.local/bin/lock-shader` is the lock entry point: it enables
  `misc:session_lock_xray` so the live shader shows _through_ hyprlock, and kills
  waybar/mako first. Bound to `SUPER CTRL L` and used as hypridle's `lock_cmd`.
  Locking with plain `hyprlock` gives you a static background instead.
- `shader-wallpaper-watch` polls `~/.config/omarchy/current/background` and re-kills
  swaybg when omarchy's theme switcher restarts it.

## Secrets

Three layers, and nothing leaks upward:

**`dotfiles-secrets`** (private repo) holds the identifiers this repo refuses to name:

```
dotfiles-secrets/
├── secrets-manifest.txt        # the 41 paths that hold credentials (~3MB of files)
├── copy-secrets.sh             # manifest-driven USB copy, in and out
└── env/
    ├── hosts.env               # internal hosts, VPN endpoint, account names, ssh key paths
    └── cx-creds.env.template   # the password variable names, no values
```

`bootstrap.sh --secrets <path-or-git-url>` clones it if needed and symlinks
`env/hosts.env` into `$SECRETS_DIR` (default `~/.local/share/secrets`). A symlink,
not a copy, so `git pull` in the secrets repo is live immediately — no second
untracked copy to rot.

**The USB** holds the credential values, and only those:

```bash
~/dotfiles-secrets/copy-secrets.sh out /run/media/$USER/<label>            # plain copy
~/dotfiles-secrets/copy-secrets.sh out /run/media/$USER/<label> --encrypt  # age tarball
~/dotfiles-secrets/copy-secrets.sh in  /run/media/$USER/<label>            # restore + fix modes
```

**At runtime**, `~/.local/scripts/load-creds.sh` sources both halves out of
`$SECRETS_DIR` — `hosts.env` from the repo, `cx-creds.env` (mode 600) from the USB.
`cx-rdp-135`, `cx-rdp-151`, `ssh237`, `cx-vpn` and `init-ssh.sh` all go through it and
reference variables only. If either half is missing they exit 1 listing both missing
paths and how to get each one, rather than failing obscurely mid-command.

`load-creds.sh` itself names no host and no credential, which is what lets the whole
`local/` package live in the less-private repo.

## Deliberately not in this repo

| Not here                                                         | Why / what to do                                                                                                                                                                                                                                                             |
| ---------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `~/.config/omarchy/themes/` minus `harbordark` (662MB)           | Every other theme is its own git clone. `omarchy-theme-install`. The active one is here, in `themes/`.                                                                                                                                                                       |
| `~/.config/hypr/shaders/`                                        | Was 138 symlinks into `/usr/share/aether/shaders/`, **all 138 broken** — the `aether` package stopped shipping them. hyprshade works off `/usr/share/hyprshade/shaders/` instead; `hyprshade.toml` only references `vibrance` and `blue-light-filter`, which do exist there. |
| chromium / Slack / Brave / Code / obsidian / Signal caches (6GB) | Cache and session state, and they hold cookies and login DBs. Only `Code/User/{settings,keybindings}.json` is kept.                                                                                                                                                          |
| `~/.local/bin/rtk` (10MB), `deviceTRUST/`                        | Prebuilt vendor binaries — reinstall from the vendor.                                                                                                                                                                                                                        |
| `graphify`, `graphify-mcp`, `hyprshade` symlinks                 | Install with `uv tool install graphifyy` and `pipx install hyprshade`. Note hyprshade is _also_ a pacman package — duplicate, pick one.                                                                                                                                      |
| `~/.crc/machines` (12GB), `~/.minikube` (793MB)                  | Regenerable cluster VM state.                                                                                                                                                                                                                                                |

## Known warts

- `monitors.conf` / `monitors.conf.bak` / `monitors.json` disagreed on monitor positions.
  `monitors.d/lap-jup-okom.conf` is taken from the live `monitors.conf`; `monitors.json`
  (hyprmon's workspace data) still holds different offsets and a stale `desc:Sony` entry.
- `~/.local/share/omarchy` carries 6 local modifications on branch `dev`, left
  uncommitted so `omarchy-update` can still fast-forward. `patches/omarchy-local-mods.patch`
  is the only copy — **re-export it after every omarchy change**, see
  "Applying the patches".
