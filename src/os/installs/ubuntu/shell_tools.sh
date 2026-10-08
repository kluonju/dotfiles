#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Shell Tools\n\n"

# Tools the dotfiles' shell scripts lean on. On macOS these are
# typically installed via Homebrew (`reattach-to-user-namespace`, …)
# so they were never installed explicitly there.

apt_install "xclip" "xclip" "--skip-update"

# `wl-clipboard` provides `wl-copy`/`wl-paste` for Wayland sessions.
# It's a no-op install on headless/CI.

if apt-cache show wl-clipboard &> /dev/null; then
    apt_install "wl-clipboard" "wl-clipboard" "--skip-update"
fi
