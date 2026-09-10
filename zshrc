# --- Path ---
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="$HOME/.config/ghq/github.com/aidyak/dotfiles/bin:$PATH"

# --- ghq ---
export GHQ_ROOT="$HOME/.config/ghq"

# --- Mise (version manager) ---
eval "$(mise activate zsh)"

# --- Prompt: Starship ---
export STARSHIP_CONFIG="$HOME/.config/ghq/github.com/aidyak/dotfiles/config/starship/starship.toml"
eval "$(starship init zsh)"

# --- Catppuccin Macchiato for zsh-syntax-highlighting ---
source "$HOME/.zsh/catppuccin-zsh-syntax-highlighting/themes/catppuccin_macchiato-zsh-syntax-highlighting.zsh" 2>/dev/null

# --- Plugins ---
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" 2>/dev/null
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" 2>/dev/null
source "$(brew --prefix)/share/zsh-abbr/zsh-abbr.zsh" 2>/dev/null

# --- Terminal ---
export TERM="xterm-256color"
export EDITOR="code --wait"
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

# --- Abbreviations (zsh-abbr) ---
abbr add --force nn="nvim"
abbr add --force ls="eza --icons"
abbr add --force ll="eza -l"
abbr add --force rst="exec $SHELL -l"
abbr add --force gst="git status"

# --- Functions ---
mkcd () { mkdir -p "$1" && cd "$1"; }
cdl () { cd "$1" && ls -la; }
most_used () {
  history | awk '{a[$2]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head
}

# --- fzf ---
source <(fzf --zsh) 2>/dev/null
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'

# ghq + fzf: Ctrl+G でリポジトリ選択して移動
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
