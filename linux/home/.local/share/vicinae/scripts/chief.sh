#!/usr/bin/env bash
# @vicinae.schemaVersion 1
# @vicinae.title chief
# @vicinae.mode compact
# @vicinae.icon 🎩
# @vicinae.keywords ["dashboard", "status", "node", "agent"]
# @vicinae.description Live status of Chief and everything it can do, in a ghostty window.
# Copied to ~/.local/share/vicinae/scripts/chief.sh (tracked in the dotfiles
# repo), so it resolves the launcher next to itself first, then the repo.
here="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
launcher="$here/chief-dash.sh"
[ -x "$launcher" ] || launcher="${CHIEF_REPO:-$HOME/Documents/hack/chief}/ops/pc/chief-dash.sh"
CHIEF_DASH_WINDOW=1 exec "$launcher"
