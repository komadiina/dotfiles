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
bg=$HOME/.config/omarchy/current/theme/backgrounds; rm -rf $bg && mkdir -p $bg
cp assets/dragonflight.jpeg $HOME/.config/omarchy/current/theme/backgrounds/dragonflight.jpeg
hyprctl reload
# edit ~/.zshrc to not source ~/.local/scripts/load-creds.sh
```

- stow (may require tweaks from your side, e.g. backing up existing configuration/dotfiles somewhere else & force overriding):

```
./boostrap.sh
```
