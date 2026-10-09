#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Miscellaneous\n\n"

apt_install "VLC"   "vlc"                 "--skip-update"
apt_install "Xarchiver" "xarchiver"        "--skip-update"

# Rectangle (macOS window-tiling) has a near-equivalent in
# `gnome-shell-extension-window-tiler` or, more commonly, the user
# installs `tilingshell` from a third-party repo. Print a hint and move on.

print_warning "Window tiling: install 'tilingshell' or 'gnome-shell-extension-gsnap'"
