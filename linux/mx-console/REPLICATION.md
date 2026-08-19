# MX Creative Console + Bitfocus Companion on Ubuntu

How to recreate the working keypad setup on a fresh machine. Verified on Ubuntu 24.04 (noble), GNOME on Wayland, with the MX Creative Console keypad (USB ID `046d:c354`) and Companion installed under `/opt/companion`.

## How it works

Companion drives the keypad's 9 LCD keys through its Logitech MX Creative Console surface plugin (the wireless dial pad is not supported). Every button runs the same script with a different argument, `~/.local/bin/mxpad <action>`, via Companion's built-in action *System: Run shell path (local)*. That keeps Companion a dumb button grid; all behavior lives in one editable file.

`mxpad` relies on three helpers, two of them forced by Wayland:

- Activate Window By Title (GNOME extension) — Wayland doesn't let scripts focus windows, so "focus Cursor if it's open, else launch it" has to ask GNOME Shell over D-Bus.
- ydotool 1.0 with its user daemon — Wayland rejects X11-style fake input, so keystrokes are injected at the kernel level through `/dev/uinput`.
- playerctl for media control.

Dictation (Handy) toggles via a Unix signal, no helper needed. There are two pages of 9 actions; the keypad's two pager keys flip Companion pages.

In this repo:

    icons/                                         18 button icons, 288x288; filename encodes page and key position
    ../home/.local/bin/mxpad                       the dispatcher (also inlined at the bottom of this file)
    ../home/.config/systemd/user/ydotoold.service  systemd user unit for the ydotool daemon

Stow deploys the two `../home/` files with the rest of the dotfiles (see `../README.md`), which covers the copy steps in phases 2 and 4.

## Phase 0 — traps

Each of these cost real debugging time; read them before typing anything.

1. Don't `apt install ydotool` on Ubuntu 24.04. Noble ships 0.1.8, which takes key names instead of `keycode:1/:0` pairs and hardcodes its socket in `/tmp`. `mxpad` needs 1.0.x, built from source (phase 2). If apt's version is already installed, remove it first.
2. udev `MODE` rules at `50-` priority can be overridden by later system rules. You may not need a rule at all: logind grants the active user an ACL on the keypad's hidraw node (`crw-rw----+`), which is enough for Companion. If access is missing, install the rule as `99-` so it runs last.
3. Adding yourself to the `input` group (needed for `/dev/uinput`) requires a full reboot to reach systemd user services; logging out can be insufficient.
4. Companion's MX Creative Console surface plugin ships disabled. Until you turn it on in Settings → Surfaces, the keypad will never be detected.
5. Run Companion as your desktop user, never as root or a system service: the buttons need your session's D-Bus and Wayland environment. `/opt/companion` installs don't register a `.desktop` file, so autostart is set up by hand (phase 5).
6. Installing GNOME extensions from a browser fails without the browser connector (a "No Apps Available" dialog). Use the Extension Manager app instead (phase 3).
7. Window-class matching is exact and case-sensitive. If a focus-or-launch button opens duplicate windows, the WM_CLASS in `mxpad` doesn't match reality; check real classes in Looking Glass (Alt+F2 → `lg` → Windows tab) or match by title substring instead.

## Phase 1 — base packages

```bash
sudo apt update
sudo apt install playerctl cmake build-essential scdoc git gnome-shell-extension-manager
sudo snap install ghostty --classic   # terminal used by the btop/terminal/lazygit/claude-code buttons
```

No ydotool here on purpose (trap 1). If it's already installed: `sudo apt remove ydotool`.

## Phase 2 — ydotool 1.0.x from source, plus its daemon

```bash
git clone https://github.com/ReimuNotMoe/ydotool.git
cd ydotool && mkdir build && cd build
cmake .. && make -j$(nproc)
sudo make install          # -> /usr/local/bin/ydotool, /usr/local/bin/ydotoold
which ydotool              # must print /usr/local/bin/ydotool
```

Give your user access to `/dev/uinput` and load the module at boot:

```bash
echo 'KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"' \
  | sudo tee /etc/udev/rules.d/80-uinput.rules
echo uinput | sudo tee /etc/modules-load.d/uinput.conf
sudo modprobe uinput
sudo usermod -aG input $USER
```

The daemon runs as a systemd user service. The unit is `../home/.config/systemd/user/ydotoold.service`, deployed by stow; to copy it manually instead:

```bash
mkdir -p ~/.config/systemd/user
cp ../home/.config/systemd/user/ydotoold.service ~/.config/systemd/user/
```

```ini
# ~/.config/systemd/user/ydotoold.service
[Unit]
Description=ydotool user daemon (uinput keystroke injection for Wayland)

[Service]
ExecStart=/usr/local/bin/ydotoold --socket-path=%t/.ydotool_socket
Restart=on-failure

[Install]
WantedBy=default.target
```

Reboot now (trap 3), then:

```bash
systemctl --user enable --now ydotoold
YDOTOOL_SOCKET=/run/user/$(id -u)/.ydotool_socket ydotool type hello   # must type "hello"
```

## Phase 3 — GNOME extension for focus-or-launch

Open Extension Manager (installed in phase 1), go to the Browse tab, search for "Activate Window By Title" (author lucaswerkmeister), install. No configuration. To verify, with any app window open:

```bash
gdbus call --session --dest org.gnome.Shell \
  --object-path /de/lucaswerkmeister/ActivateWindowByTitle \
  --method de.lucaswerkmeister.ActivateWindowByTitle.activateBySubstring "Vivaldi"
# (true,) if a Vivaldi window exists, (false,) if not; an interface error means the extension isn't active
```

## Phase 4 — dispatcher, keybindings, app tweaks

The dispatcher lives at `../home/.local/bin/mxpad` and is deployed by stow. To copy it manually instead:

```bash
mkdir -p ~/.local/bin
cp ../home/.local/bin/mxpad ~/.local/bin/
chmod +x ~/.local/bin/mxpad
```

Then adjust the lines marked `EDIT:` in the script: the lazygit `--working-directory` (point it at your main repo), and the launch commands for Cursor, Claude Desktop, and Spotify if they're AppImages or Flatpaks (use absolute paths, e.g. `$HOME/Applications/Cursor.AppImage`).

The fullscreen button presses a shortcut that GNOME leaves unbound by default, so bind it once:

```bash
gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen "['<Control><Super>f']"
```

Two things need doing in the apps themselves. In Vivaldi, open `vivaldi://settings/keyboard` and bind Ctrl+Period to "Next Workspace"; `mxpad vivaldi-ws` presses it, and Vivaldi cycles its own workspaces. Handy needs no configuration — `mxpad voice` sends `SIGUSR2`, Handy's documented Wayland toggle — but it should be installed (AppImage in `~/Applications`), have a model downloaded, and autostart.

Smoke test: `mxpad terminal`, `mxpad pause`, `mxpad fullscreen` (with a window focused).

## Phase 5 — Companion install, autostart, keypad detection

1. Install Companion 4.1 or newer from https://user.bitfocus.io/download. On the verified machine it lives in `/opt/companion`.

2. Create the autostart entry — `/opt` installs don't register a `.desktop` file. Check `ls /opt/companion` for the actual launcher binary and adjust `Exec`:

```ini
# ~/.config/autostart/companion.desktop
[Desktop Entry]
Type=Application
Name=Bitfocus Companion
Exec=/opt/companion/companion-launcher
X-GNOME-Autostart-enabled=true
```

3. Plug the keypad in via USB and check that the kernel sees it and you can read it:

```bash
lsusb | grep -i 046d                                    # expect ...046d:c354... MX Creative Keypad
grep -iH 046D /sys/class/hidraw/hidraw*/device/uevent   # tells you which hidrawN is the keypad
ls -l /dev/hidrawN                                      # want group-rw with '+' (an ACL) or rw-rw-rw-
getfacl /dev/hidrawN                                    # want a user:<you>:rw- line
```

Only if no ACL or mode grants you access:

```bash
echo 'KERNEL=="hidraw*", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c354", MODE="0666"' \
  | sudo tee /etc/udev/rules.d/99-logitech-mx.rules     # 99- so nothing overrides it (trap 2)
sudo udevadm control --reload-rules
# then unplug and replug the keypad; rules apply on connect
```

4. Open the Companion UI at http://localhost:8000. Settings → Surfaces → enable "Logitech MX Creative Console" (trap 4), then Surfaces tab → Rescan USB. The keypad appears and Companion takes over the LCDs. When Companion isn't running the keypad shows Logitech's firmware screens; that's normal.

## Phase 6 — button layout

If you can still reach the original machine, skip the manual build: export the config there (Companion UI → Import / Export → export `.companionconfig`), import it on the new machine, and pages, icons, and actions all come across. Only phases 1–5 remain. Otherwise, build by hand:

The grid is 4 rows by 3 columns per page. Rows 1–3 are the 9 LCD keys in reading order 0–8; row 4 is the two physical pager keys under the LCDs.

For each of the 18 action buttons: create a Regular button, upload the matching PNG from `icons/` (the filename tells you where it goes), clear the button text, and add the action *internal: System: Run shell path (local)* with path `/home/<USER>/.local/bin/mxpad <action>`. The path must be absolute; Companion's shell has no user environment.

| Page 1 key | action | Page 2 key | action |
|---|---|---|---|
| 0 | `btop` | 0 | `ws-left` |
| 1 | `terminal` | 1 | `ws-right` |
| 2 | `fullscreen` | 2 | `claude` |
| 3 | `cursor` | 3 | `pause` |
| 4 | `screenshot` | 4 | `spotify` |
| 5 | `lazygit` | 5 | `next` |
| 6 | `claude-code` | 6 | `vivaldi` |
| 7 | `voice` | 7 | `vivaldi-ws` |
| 8 | `accept` | 8 | `youtube` |

The pager keys in row 4 must be set up on both pages, since buttons don't carry across pages; copy-paste them. Left cell gets button type "Page down", right cell "Page up". These are special button types with no actions. Swap them if the direction feels inverted.

When everything works, export a fresh `.companionconfig` backup.

## Appendix — the dispatcher (`~/.local/bin/mxpad`)

```bash
#!/usr/bin/env bash
# mxpad — dispatcher for Logitech MX Creative Console buttons (Bitfocus Companion)
# Each Companion button runs:  /home/YOU/.local/bin/mxpad <action>
set -u
export YDOTOOL_SOCKET="${YDOTOOL_SOCKET:-/run/user/$(id -u)/.ydotool_socket}"

# Linux input key codes used below:
# 28=ENTER  29=LEFTCTRL  33=F  52=DOT  99=PRINT  104=PAGEUP  109=PAGEDOWN  125=SUPER

focus() { # focus <method> <arg> — returns 0 if an existing window was activated
  local out
  out=$(gdbus call --session --dest org.gnome.Shell \
        --object-path /de/lucaswerkmeister/ActivateWindowByTitle \
        --method "de.lucaswerkmeister.ActivateWindowByTitle.$1" "$2" 2>/dev/null)
  [[ "$out" == *true* ]]
}

launch() { setsid -f "$@" >/dev/null 2>&1; }

case "${1:-}" in
  # ================= PAGE 1 — shortcuts & AI =================
  btop)        launch /snap/bin/ghostty --title=btop -e btop ;;
  terminal)    launch /snap/bin/ghostty ;;   # new window; absolute snap path, Companion's shell has no user PATH
  fullscreen)  ydotool key 29:1 125:1 33:1 33:0 125:0 29:0 ;;   # Ctrl+Super+F -> GNOME toggle-fullscreen
  cursor)      focus activateByWmClass "Cursor" || launch cursor ;;   # EDIT: AppImage path if needed
  screenshot)  ydotool key 99:1 99:0 ;;   # Print -> GNOME screenshot UI (region mode is sticky default)
  lazygit)     launch /snap/bin/ghostty --title=lazygit \
                 --working-directory="$HOME" -e lazygit ;;   # EDIT: your main repo path
  claude-code) focus activateBySubstring "claude" || \
                 launch /snap/bin/ghostty --title="Claude Code" -e bash -ic claude ;;
  voice)       pkill -USR2 -x handy ;;   # toggle Handy recording; -USR1 for post-processed mode
  accept)      ydotool key 28:1 28:0 ;;   # Enter to focused window

  # ================= PAGE 2 — desktop & media =================
  ws-left)     ydotool key 125:1 104:1 104:0 125:0 ;;   # Super+PageUp  = GNOME workspace left
  ws-right)    ydotool key 125:1 109:1 109:0 125:0 ;;   # Super+PageDown = GNOME workspace right
  claude)      focus activateByWmClass "Claude" || launch claude-desktop ;;   # EDIT: launch cmd
  pause)       playerctl -p spotify play-pause ;;
  next)        playerctl -p spotify next ;;
  spotify)     focus activateByWmClass "Spotify" || launch spotify ;;
               # flatpak: replace 'spotify' with: flatpak run com.spotify.Client
  vivaldi)     focus activateBySubstring "Vivaldi" || launch vivaldi ;;
               # substring match — activateByWmClass "vivaldi-stable" missed on the verified machine;
               # check real classes via Looking Glass (Alt+F2 -> lg -> Windows) if this misbehaves
  vivaldi-ws)  { focus activateBySubstring "Vivaldi" || launch vivaldi; }
               sleep 0.25
               ydotool key 29:1 52:1 52:0 29:0 ;;   # Ctrl+. -> "Next Workspace" (bound in Vivaldi)
  youtube)     launch vivaldi https://www.youtube.com ;;

  *) echo "unknown action: ${1:-}" >&2; exit 1 ;;
esac
```

## Appendix — verification checklist

```bash
which ydotool                                  # /usr/local/bin/ydotool
systemctl --user is-active ydotoold            # active
YDOTOOL_SOCKET=/run/user/$(id -u)/.ydotool_socket ydotool type ok   # types "ok"
gnome-extensions list --enabled | grep -i activate-window           # extension enabled
~/.local/bin/mxpad terminal                    # opens a terminal
gsettings get org.gnome.desktop.wm.keybindings toggle-fullscreen    # ['<Control><Super>f']
lsusb | grep 046d                              # keypad present
ls ~/.config/autostart/companion.desktop       # autostart in place
```
