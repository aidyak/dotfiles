# --- Dotfiles ---
export DOTFILES="$HOME/.config/ghq/github.com/aidyak/dotfiles"
export PATH="$DOTFILES/bin:$PATH"

# --- Platform ---
case "$(uname -s)" in
  Darwin)
    if [[ -x /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    ;;
  Linux)
    ;;
esac

# --- ghq ---
export GHQ_ROOT="$HOME/.config/ghq"

# --- Mise (version manager) ---
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# --- Prompt: Starship ---
export STARSHIP_CONFIG="$DOTFILES/config/starship/starship.toml"
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# --- Catppuccin Macchiato for zsh-syntax-highlighting ---
source "$HOME/.zsh/catppuccin-zsh-syntax-highlighting/themes/catppuccin_macchiato-zsh-syntax-highlighting.zsh" 2>/dev/null

# --- Plugins ---
if [[ "$(uname -s)" == "Darwin" ]] && command -v brew >/dev/null 2>&1; then
  source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" 2>/dev/null
  source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" 2>/dev/null
  source "$(brew --prefix)/share/zsh-abbr/zsh-abbr.zsh" 2>/dev/null
elif [[ "$(uname -s)" == "Linux" ]]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
fi

# --- Terminal ---
export TERM="xterm-256color"
if [[ "$(uname -s)" == "Darwin" ]] && command -v code >/dev/null 2>&1; then
  export EDITOR="code --wait"
else
  export EDITOR="nvim"
fi
export VISUAL="$EDITOR"

# --- History ---
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt APPEND_HISTORY

# --- Completion ---
autoload -Uz compinit
compinit -C

# --- Abbreviations / aliases ---
if command -v abbr >/dev/null 2>&1; then
  abbr add --force nn="nvim"
  abbr add --force ls="eza"
  abbr add --force ll="eza -l"
  abbr add --force rst="exec $SHELL -l"
  abbr add --force gst="git status"
  abbr add --force gch="git checkout"
  abbr add --force gpl="git pull"
  abbr add --force gps="git push"
  abbr add --force gpsf="git push -f"
else
  alias nn="nvim"
  alias ls="eza"
  alias ll="eza -l"
  alias rst="exec $SHELL -l"
  alias gst="git status"
  alias gch="git checkout"
  alias gpl="git pull"
  alias gps="git push"
  alias gpsf="git push -f"
fi

# --- Functions ---
mkcd () { mkdir -p "$1" && cd "$1"; }
cdl () { cd "$1" && ls -la; }
most_used () {
  history | awk '{a[$2]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head
}

# --- fzf ---
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh) 2>/dev/null
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
fi

# ghq + fzf: Ctrl+G でリポジトリ選択して移動
if command -v ghq >/dev/null 2>&1 && command -v fzf >/dev/null 2>&1; then
  function ghq-fzf() {
    local selected
    selected=$(ghq list --full-path | fzf \
      --preview 'ls -la {}' \
      --preview-window=right:50% \
      --height=50% \
      --reverse \
      --prompt='repo> ')
    if [ -n "$selected" ]; then
      cd "$selected"
    fi
    zle reset-prompt
  }
  zle -N ghq-fzf
  bindkey '^g' ghq-fzf
fi
