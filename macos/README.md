# macOS

## Deploy configs

```sh
brew install stow
cd ~/dotfiles/macos && stow -t ~ home
```

If a real file already exists where a link should go, `stow --adopt -t ~ home` pulls it into the repo instead of failing; check `git diff` afterwards to keep or discard the difference.

What gets linked:

- `.zshrc` — Oh My Zsh + Powerlevel10k, conda, nvm, sdkman, zoxide
- `.config/lazygit/config.yml` — lazygit config
- `.config/tmux/.tmux.conf` — tmux config
- `.local/bin/mxpad` — MX Creative Console button dispatcher

`.zshrc` expects Oh My Zsh with the `powerlevel10k` theme and the `zsh-autosuggestions` and `zsh-syntax-highlighting` plugins, plus `brew install zoxide fzf` (fzf powers `zi`).

## Zoxide

`z <query>` jumps to a frequently used directory, `zi <query>` picks interactively with fzf.

## MX Creative Console

Setup runbook: [`mx-console/SETUP.md`](mx-console/SETUP.md). Much shorter than the Linux one, since macOS has the needed pieces built in.
