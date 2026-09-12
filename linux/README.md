# Linux (Ubuntu 24.04, GNOME on Wayland)

## Deploy configs

```sh
sudo apt install stow
cd ~/dotfiles/linux && stow -t ~ home
```

If a real file already exists where a link should go, `stow --adopt -t ~ home` pulls it into the repo instead of failing; check `git diff` afterwards to keep or discard the difference.

What gets linked:

- `.bashrc` — Ubuntu default plus ROS, `~/.local/bin` on PATH, zoxide
- `.zshrc` — zsh (login shell): Starship prompt, fzf + fzf-tab, atuin, autosuggestions, syntax highlighting, zsh-ai, eza/bat aliases, zoxide
- `.config/starship.toml` — Starship prompt, Catppuccin Mocha
- `.config/ghostty/config` — Ghostty: Catppuccin Mocha + JetBrainsMono Nerd Font
- `.config/lazygit/config.yml` — lazygit config
- `.config/vicinae/settings.json` — Vicinae launcher config
- `.local/bin/mxpad` — MX Creative Console button dispatcher
- `.local/share/vicinae/scripts/chief.sh` — Vicinae script command: type `chief` to open the Chief dashboard (needs the chief repo at `~/Documents/hack/chief`)
- `.config/systemd/user/ydotoold.service` — keystroke-injection daemon that `mxpad` needs

## Zsh look (Starship + Nerd Font + eza + bat)

The prompt is [Starship](https://starship.rs) themed Catppuccin Mocha to match Ghostty and GRUB. On a fresh machine, install the pieces to `~/.local/bin` (no sudo needed):

```sh
# JetBrainsMono Nerd Font (prompt glyphs + eza icons)
mkdir -p ~/.local/share/fonts
curl -sSfLo /tmp/jbmono.tar.xz https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
tar -xf /tmp/jbmono.tar.xz -C ~/.local/share/fonts --wildcards 'JetBrainsMonoNerdFont-*.ttf'
fc-cache -f

# Starship prompt
curl -sSf https://starship.rs/install.sh | sh -s -- -y -b ~/.local/bin

# eza (pretty ls) and bat (pretty cat) — static binaries from GitHub releases
# https://github.com/eza-community/eza/releases  |  https://github.com/sharkdp/bat/releases
```

`.zshrc` degrades gracefully: the eza/bat aliases only activate when the binaries exist.

## Zoxide

`z <query>` jumps to a frequently used directory, `zi <query>` picks interactively with fzf. Install with the upstream script — Ubuntu's apt package lags behind:

```sh
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
```

It lands in `~/.local/bin`, which `.bashrc` already puts on PATH. `zi` needs fzf 0.51+, newer than apt's; get it from https://github.com/junegunn/fzf/releases if wanted.

## Vicinae

[Vicinae](https://vicinae.com) is a Raycast-style launcher, running as a systemd user service (`vicinae.service`). Its config is in `home/.config/vicinae/settings.json`.

### Script commands

Plain scripts with `# @vicinae.*` headers in `~/.local/share/vicinae/scripts/` show up in the root search. `chief.sh` opens `chief-dash`, the terminal dashboard from the [chief](https://github.com/jurmy24/chief) repo, in a ghostty window. After adding a script, run the "Reload Script Directories" command (or `vicinae cmd launch core:reload-scripts`).

### Color picker extension

The color picker from the Vicinae store shells out to `grim`/`slurp`, which only work on wlroots compositors — not GNOME. [vicinae-color-picker](https://github.com/jurmy24/vicinae-color-picker) picks colors through the XDG desktop portal instead, so it works on GNOME (X11 and Wayland) and KDE too. Install:

```sh
git clone git@github.com:jurmy24/vicinae-color-picker.git ~/vicinae-color-picker
cd ~/vicinae-color-picker && npm install && npm run build
systemctl --user restart vicinae
```

`npm run build` installs it straight into `~/.local/share/vicinae/extensions/`. This adds a **Pick Color** command (bind it to a shortcut in Vicinae for a one-keystroke eyedropper) and a **Color History** browser.

### Cheatsheets extension

I never remember tmux keys. [vicinae-cheatsheets](https://github.com/jurmy24/vicinae-cheatsheets) (private repo) adds a **tmux** command to Vicinae that pops a small always-on-top window in the top right corner with the keys, and closes it when run again. The sheets themselves live in that repo's `sheets/` folder, and creating one from Vicinae commits and pushes it there, so they are not duplicated here. Install:

```sh
git clone git@github.com:jurmy24/vicinae-cheatsheets.git ~/vicinae-cheatsheets
cd ~/vicinae-cheatsheets && npm install && npm run build
systemctl --user restart vicinae
```

## GRUB

Dual-boot menu (Ubuntu + Windows) with the Catppuccin Mocha theme, HiDPI-tweaked. Config and theme live in [`grub/`](grub/SETUP.md); these are system files, so they're copied with sudo rather than stowed.

## MX Creative Console

The full fresh-machine runbook is [`mx-console/REPLICATION.md`](mx-console/REPLICATION.md): packages, ydotool from source, GNOME extension, Companion, and the button layout. The `home/` files above only cover the dispatcher and daemon.
