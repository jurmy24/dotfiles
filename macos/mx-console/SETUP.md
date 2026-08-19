# MX Creative Console + Bitfocus Companion on macOS

Same idea as the Linux setup (`../../linux/mx-console/REPLICATION.md`): Companion drives the keypad's 9 LCD keys, every button runs `~/.local/bin/mxpad <action>`, and the pager keys flip between two pages. None of the Linux plumbing is needed here. `open -a` already means "focus if running, else launch", and `osascript` injects keystrokes, so there's no ydotool, no daemon, no GNOME extension, no udev rules.

Not yet verified on the Mac; the two VERIFY notes below are the open questions.

## 1 — dispatcher

Stow deploys `mxpad` with the rest of `macos/home/` (see `../README.md`). Then adjust the lines marked `EDIT:` in `~/.local/bin/mxpad`: the lazygit repo path, and the `term()` helper if you use iTerm or Ghostty instead of Terminal.app.

Smoke test — neither of these needs special permissions:

```sh
mxpad terminal
mxpad pause     # with Spotify running; the first run asks to allow controlling Spotify
```

## 2 — permissions

System Settings → Privacy & Security → Accessibility → add Companion. Every keystroke action (`fullscreen`, `screenshot`, `accept`, `ws-left`/`ws-right`, `vivaldi-ws`) fails silently without it. macOS may also prompt for Automation (Companion controlling System Events or Spotify) on first press; allow it.

## 3 — Companion

1. Install Companion 4.1 or newer from https://user.bitfocus.io/download, launch it, and add it as a Login Item (System Settings → General → Login Items).
2. If Logi Options+ is installed, quit it and disable its launch-at-login — it grabs the keypad. (VERIFY whether Companion can share the device with it.)
3. In the Companion UI at http://localhost:8000: Settings → Surfaces → enable "Logitech MX Creative Console" (ships disabled), then Surfaces tab → Rescan USB.

## 4 — buttons

If `backup.companionconfig` exists in this folder, import it (Companion UI → Import / Export) and you're done. Otherwise build the buttons exactly as in the Linux runbook, phase 6 — same grid, same `icons/`, same action table — except the shell path is `/Users/YOU/.local/bin/mxpad <action>`.

## 5 — app-side bindings

- Vivaldi: open `vivaldi://settings/keyboard` and bind Ctrl+Period to "Next Workspace".
- Handy: VERIFY the `voice` action. `mxpad` sends `SIGUSR2`, which is Handy's documented toggle on Linux. If the mac build ignores signals, set a global shortcut in Handy and have `mxpad voice` press it via `key()` instead.

When everything works, export a `.companionconfig` from the Companion UI into this folder as `backup.companionconfig`.
