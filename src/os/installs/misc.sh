#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Miscellaneous\n\n"

apt_install "VLC"       "vlc"     "--skip-update"
apt_install "Xarchiver" "xarchiver" "--skip-update"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Chinese input method (Fcitx5 + Chinese addons).

# Install Fcitx5 core and Chinese input engine.
apt_install "Fcitx5 core"      "fcitx5"                            "--skip-update"
apt_install "Fcitx5 Chinese"   "fcitx5-chinese-addons"             "--skip-update"
apt_install "Fcitx5 GTK3"      "fcitx5-frontend-gtk3"              "--skip-update"
apt_install "Fcitx5 GTK4"      "fcitx5-frontend-gtk4"              "--skip-update"
apt_install "Fcitx5 Qt5"       "fcitx5-frontend-qt5"               "--skip-update"

# Install the configuration tool.
apt_install "Fcitx5 config tool" "fcitx5-config-qt"               "--skip-update"

# Set Fcitx5 as the default input method framework.
#
# `im-config -n fcitx5` is idempotent — it rewrites the user's
# `~/.xinputrc` to point at the fcitx5 profile. Safe to re-run.

execute \
    "im-config -n fcitx5" \
    "Set Fcitx5 as default input method"

# Rectangle (macOS window-tiling) has a near-equivalent in
# `gnome-shell-extension-window-tiler` or, more commonly, the user
# installs `tilingshell` from a third-party repo. Print a hint and move on.

print_warning "Window tiling: install 'tilingshell' or 'gnome-shell-extension-gsnap'"
