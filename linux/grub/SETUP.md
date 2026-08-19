# GRUB

Boot menu for the dual-boot PC (Ubuntu + Windows), themed with Catppuccin Mocha.

In this folder:

    grub                                copy of /etc/default/grub
    themes/catppuccin-mocha-grub-theme  the theme as installed, including HiDPI tweaks

What `grub` changes from Ubuntu defaults:

- `GRUB_TIMEOUT_STYLE=menu`, `GRUB_TIMEOUT=10` — always show the menu for 10 seconds so Windows is pickable
- `GRUB_DISABLE_OS_PROBER=false` — detect the Windows install and add it to the menu
- `GRUB_GFXMODE=1920x1080,auto` — readable resolution on the 4K display
- `GRUB_THEME=` pointing at the theme below

The theme started as [catppuccin/grub](https://github.com/catppuccin/grub) (mocha flavor) but was then tuned for HiDPI: the font was regenerated at a larger size and the icons and selector images upscaled, and the logo swapped. The upstream repo doesn't have these changes, which is why the whole theme is archived here. The pre-tweak originals still sit next to the live files as `*.bak-pre-hidpi` on the machine, but aren't tracked.

## Restore

```sh
sudo cp grub /etc/default/grub
sudo cp -r themes/catppuccin-mocha-grub-theme /usr/share/grub/themes/
sudo update-grub    # should print "Found Windows Boot Manager" if os-prober sees it
```

Then reboot and check the menu: themed, 10-second countdown, Windows entry present.
