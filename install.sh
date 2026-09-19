#!/usr/bin/env bash
# Rebuild this machine from a fresh Arch install.
#
# Run the steps in order. It is deliberately NOT one blind command: HyDE's own
# installer is interactive and reboots expectations, so you want to be present.
#
#   ./install.sh packages   # yay + repo/AUR packages from the manifests
#   ./install.sh hyde       # clone + run the HyDE installer
#   ./install.sh dotfiles   # stow this repo over HyDE's defaults + bootstrap
#   ./install.sh services   # enable the systemd units that were enabled here
#   ./install.sh tools      # oh-my-zsh, nvim plugins, Mason tools
#
set -euo pipefail
cd "$(dirname "$0")"
HYDE_COMMIT="51b6cbf"   # the HyDE revision this config was built against

step_packages() {
  command -v yay >/dev/null || {
    sudo pacman -S --needed --noconfirm git base-devel
    tmp=$(mktemp -d); git clone https://aur.archlinux.org/yay.git "$tmp/yay"
    (cd "$tmp/yay" && makepkg -si --noconfirm); rm -rf "$tmp"
  }
  sudo pacman -S --needed --noconfirm - < packages/pacman-native.txt
  yay -S --needed --noconfirm - < packages/pacman-aur.txt
}

step_hyde() {
  [ -d "$HOME/HyDE" ] || git clone https://github.com/HyDE-Project/HyDE "$HOME/HyDE"
  cd "$HOME/HyDE"
  git checkout "$HYDE_COMMIT" 2>/dev/null || echo "note: pinned commit unavailable, using default branch"
  cd Scripts 2>/dev/null || cd "$HOME/HyDE"
  echo ">> run HyDE's installer now (interactive):  ./install.sh"
  echo ">> then re-run:  $OLDPWD/install.sh dotfiles"
}

step_dotfiles() {
  command -v stow >/dev/null || sudo pacman -S --needed --noconfirm stow
  # HyDE ships its own copies of these files; --adopt pulls whatever is on disk
  # into the repo and symlinks it, so check `git diff` afterwards and `git
  # checkout .` to keep THIS repo's version (which is almost always what you want).
  stow --adopt -t "$HOME" hypr waybar kitty zsh tmux starship hyde nvim bin
  echo ">> review: git -C $(pwd) diff     (then: git checkout . to keep the repo's version)"
  ./bootstrap.sh
}

step_services() {
  while read -r u; do [ -n "$u" ] && sudo systemctl enable "$u" || true; done < packages/services-system.txt
  while read -r u; do [ -n "$u" ] && systemctl --user enable "$u" || true; done < packages/services-user.txt
}

step_tools() {
  [ -d "$HOME/.oh-my-zsh" ] || git clone https://github.com/ohmyzsh/ohmyzsh "$HOME/.oh-my-zsh"
  # zsh-256color is hardcoded into HyDE's plugin list; bootstrap.sh links it in
  [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-256color" ] || \
    git clone https://github.com/chrissicool/zsh-256color \
      "$HOME/.oh-my-zsh/custom/plugins/zsh-256color"
  ./bootstrap.sh
  # lazy.nvim restores the exact plugin revisions from lazy-lock.json
  nvim --headless "+Lazy! restore" +qa
  # Mason tools are NOT tracked; reinstall the ones this config expects
  nvim --headless -c 'MasonInstall yamllint ansible-lint gitlint curlylint autotools-language-server tailwindcss-language-server' -c 'sleep 60' -c 'qa!' || true
  hyde-shell reload || true
}

case "${1:-}" in
  packages) step_packages ;;
  hyde)     step_hyde ;;
  dotfiles) step_dotfiles ;;
  services) step_services ;;
  tools)    step_tools ;;
  *) sed -n '2,14p' "$0"; exit 1 ;;
esac
