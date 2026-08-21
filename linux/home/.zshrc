# ~/.zshrc — zsh with Starship (Catppuccin Mocha), fzf, atuin, and zsh-ai.

# ---------------------------------------------------------------- environment
export PATH="$HOME/.local/bin:$PATH"

# ------------------------------------------------------------------- history
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY          # share history across sessions
setopt HIST_IGNORE_ALL_DUPS   # no duplicate entries
setopt HIST_IGNORE_SPACE      # commands starting with a space stay out
setopt HIST_REDUCE_BLANKS

setopt AUTO_CD                # `..` or a bare dir name cds into it
setopt INTERACTIVE_COMMENTS   # allow # comments on the command line

# --------------------------------------------------------- catppuccin mocha
# One place for the colors fzf and the line editor use.
export FZF_DEFAULT_OPTS="
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
  --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
  --color=selected-bg:#45475a --border=rounded --height=60%"

# Autosuggestion ghost text in a muted overlay grey
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6c7086"

# --- managed by setup-ghostty-ai-terminal (BEGIN) ---
# API key / provider for the "#" AI feature
[ -f "$HOME/.config/zsh-ai.env" ] && source "$HOME/.config/zsh-ai.env"

# atuin on PATH
export PATH="$HOME/.atuin/bin:$PATH"

# Completion system (required before fzf-tab)
autoload -Uz compinit && compinit

# fzf key bindings + completion (Ctrl-T files, Alt-C cd, etc.)
if command -v fzf >/dev/null 2>&1; then
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  else
    [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
    [ -f /usr/share/doc/fzf/examples/completion.zsh ]   && source /usr/share/doc/fzf/examples/completion.zsh
  fi
fi

# fzf-tab: MUST load after compinit and before the wrappers below
source "$HOME/.zsh/fzf-tab/fzf-tab.plugin.zsh"

# Grey "ghost text" autocomplete from history — accept with the Right arrow
source "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"

# zsh-ai: type  # find files bigger than 1GB   then Enter, and it writes the command
source "$HOME/.zsh-ai/zsh-ai.plugin.zsh"

# Better history search on Ctrl-R (up-arrow left as normal history)
command -v atuin >/dev/null 2>&1 && eval "$(atuin init zsh --disable-up-arrow)"

# Syntax highlighting MUST be sourced last
source "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
# --- managed by setup-ghostty-ai-terminal (END) ---

# ---------------------------------------------------------------- completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no                              # let fzf-tab drive
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons=always $realpath'
zstyle ':fzf-tab:complete:z:*'  fzf-preview 'eza -1 --color=always --icons=always $realpath'

# ------------------------------------------------------------------- aliases
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='eza -l --icons=auto --group-directories-first --git'
  alias la='eza -la --icons=auto --group-directories-first --git'
  alias lt='eza --tree --level=2 --icons=auto'
fi
command -v bat >/dev/null 2>&1 && alias cat='bat --paging=never'

# ------------------------------------------------------------ zoxide + prompt
eval "$(zoxide init zsh)"      # z <query> jumps, zi picks interactively
eval "$(starship init zsh)"
