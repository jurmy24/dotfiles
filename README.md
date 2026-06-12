# Dotfiles

Minimal personal dotfiles.

## Files

- `.zshrc` - Oh My Zsh setup, including zoxide.
- `.config/lazygit/config.yml` - Lazygit config.
- `.config/tmux/.tmux.conf` - Tmux config.

## Zoxide

Use `z <query>` to jump to a frequently used directory, and `zi <query>` to choose interactively with fzf.

## Restore

For now, copy files manually as needed.

If this repo later uses GNU Stow:

```sh
brew install stow
cd ~/Documents/Hack/dotfiles
stow -t ~ .
```
