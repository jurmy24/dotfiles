# Linux (Ubuntu 24.04, GNOME on Wayland)

## Deploy configs

```sh
sudo apt install stow
cd ~/dotfiles/linux && stow -t ~ home
```

If a real file already exists where a link should go, `stow --adopt -t ~ home` pulls it into the repo instead of failing; check `git diff` afterwards to keep or discard the difference.

What gets linked:

- `.bashrc` — Ubuntu default plus ROS, `~/.local/bin` on PATH, zoxide
- `.config/lazygit/config.yml` — lazygit config
- `.local/bin/mxpad` — MX Creative Console button dispatcher
- `.config/systemd/user/ydotoold.service` — keystroke-injection daemon that `mxpad` needs

## Zoxide

`z <query>` jumps to a frequently used directory, `zi <query>` picks interactively with fzf. Install with the upstream script — Ubuntu's apt package lags behind:

```sh
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
```

It lands in `~/.local/bin`, which `.bashrc` already puts on PATH. `zi` needs fzf 0.51+, newer than apt's; get it from https://github.com/junegunn/fzf/releases if wanted.

## GRUB

Dual-boot menu (Ubuntu + Windows) with the Catppuccin Mocha theme, HiDPI-tweaked. Config and theme live in [`grub/`](grub/SETUP.md); these are system files, so they're copied with sudo rather than stowed.

## MX Creative Console

The full fresh-machine runbook is [`mx-console/REPLICATION.md`](mx-console/REPLICATION.md): packages, ydotool from source, GNOME extension, Companion, and the button layout. The `home/` files above only cover the dispatcher and daemon.
