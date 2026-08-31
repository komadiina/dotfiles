# installation guide

- non-stow (no symlinks except walker@/usr/local/bin)

```bash
sudo pacman -S --needed git stow base-devel rust
sudo pacman -S --needed - <packages/pacman-explicit.txt
yay -S --needed - <packages/aur-explicit.txt
git -C ~/.local/share/omarchy apply $(pwd)/patches/omarchy-local-mods.patch
git clone -b highlight-matches git@github.com:komadiina/walker.git $(pwd)/.tmp/walker
cd .tmp/walker && cargo build --release --manifest-path .tmp/walker/Cargo.toml
cp .tmp/walker/target/release/walker $HOME/.local/walker
sudo ln -sfn $HOME/.local/walker /usr/local/bin/walker
cd home && cp . $HOME -r
cd config/.config && cp . $HOME/.config/ -r
cd local/.local && cp . $HOME/.local -r
cd themes/harbordark && cp . $HOME/.config/omarchy/current/theme -r
bg=$HOME/.config/omarchy/current/theme/backgrounds; rm -rf $bg && mkdir -p $bg
cp assets/dragonflight.jpeg $HOME/.config/omarchy/current/theme/backgrounds/dragonflight.jpeg
mv $HOME/.oh-my-zsh $HOME/.oh-my-zsh.bak-$(date +%T | sed 's/ /-/g')
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
hyprctl reload
# edit ~/.zshrc to not source ~/.local/scripts/load-creds.sh
```

- stow (may require tweaks from your side, e.g. backing up existing configuration/dotfiles somewhere else & force overriding):

```
./boostrap.sh
```

- symlinks by hand (no stow; mirrors what `stow --no-folding` does, one link per file):

```bash
DOTS="$(pwd)"
for pkg in home local config; do
  (cd "$DOTS/$pkg" && find . -type f -printf '%P\n') | while read -r rel; do
    live="$HOME/$rel"
    [ -e "$live" ] && [ ! -L "$live" ] && mv "$live" "$live.bak-$(date +%s)"
    mkdir -p "$(dirname "$live")"
    ln -sfn "$DOTS/$pkg/$rel" "$live"
  done
done
# per-host monitors + theme symlinks that stow skips (see .stow-local-ignore)
HOST="$(hostnamectl hostname 2>/dev/null || cat /etc/hostname)"
[ -f "$DOTS/config/.config/hypr/monitors.d/$HOST.conf" ] \
  && ln -sfn "$DOTS/config/.config/hypr/monitors.d/$HOST.conf" "$HOME/.config/hypr/monitors.conf"
ln -sfn "$HOME/.config/omarchy/current/theme/btop.theme" "$HOME/.config/btop/themes/current.theme"
mkdir -p "$HOME/.config/nvim/lua/plugins"
ln -sfn "$HOME/.config/omarchy/current/theme/neovim.lua" "$HOME/.config/nvim/lua/plugins/theme.lua"
hyprctl reload
```
