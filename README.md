# dotfiles

Personal dotfiles for macOS and Arch Linux.

## Arch Linux

Clone the repository to the path expected by the shell configuration:

```sh
mkdir -p ~/.config/ghq/github.com/aidyak
git clone https://github.com/aidyak/dotfiles.git ~/.config/ghq/github.com/aidyak/dotfiles
cd ~/.config/ghq/github.com/aidyak/dotfiles
```

Run the Arch bootstrap:

```sh
bash bootstrap-arch.sh
```

The script installs the required packages with pacman and links:

- `~/.zshrc`
- `~/.gitconfig`
- `~/.config/nvim`
- `~/.config/mise`
- `~/.config/starship`
- `~/.config/alacritty`

Existing files are backed up before they are replaced.

To use zsh as the login shell:

```sh
chsh -s /usr/bin/zsh
```

Then start a new login session or run:

```sh
exec zsh
```

The shared `zshrc` detects macOS and Linux. Homebrew-specific setup is only loaded on macOS, while Arch uses the packaged zsh plugins under `/usr/share/zsh/plugins`.
