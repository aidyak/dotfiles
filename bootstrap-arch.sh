#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]] || [[ ! -f /etc/arch-release ]]; then
  echo "This bootstrap script is for Arch Linux."
  exit 1
fi

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.config/ghq/github.com/aidyak/dotfiles}"

packages=(
  git
  base-devel
  zsh
  neovim
  alacritty
  starship
  mise
  fzf
  fd
  eza
  ripgrep
  zsh-autosuggestions
  zsh-syntax-highlighting
)

echo "Installing Arch packages..."
sudo pacman -Syu --needed --noconfirm "${packages[@]}"

mkdir -p "$HOME/.config"

link() {
  local source="$1"
  local target="$2"

  if [[ -L "$target" && "$(readlink -f "$target")" == "$(readlink -f "$source")" ]]; then
    echo "skip: $target"
    return
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    local backup="${target}.bak.$(date +%Y%m%d%H%M%S)"
    echo "backup: $target -> $backup"
    mv "$target" "$backup"
  fi

  ln -s "$source" "$target"
  echo "link: $target -> $source"
}

link "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
link "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"
link "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"
link "$DOTFILES_DIR/config/mise" "$HOME/.config/mise"
link "$DOTFILES_DIR/config/starship" "$HOME/.config/starship"
link "$DOTFILES_DIR/config/alacritty" "$HOME/.config/alacritty"

if [[ "$SHELL" != "/usr/bin/zsh" ]]; then
  echo
  echo "To make zsh your login shell, run:"
  echo "  chsh -s /usr/bin/zsh"
fi

echo
echo "Arch dotfiles setup complete."
echo "Start a new shell with: exec zsh"
