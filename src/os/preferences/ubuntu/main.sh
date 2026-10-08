#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n • Preferences\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# macOS preferences target `defaults write` and `osascript` to drive
# individual System Preferences panes. On Ubuntu the equivalents are
# `gsettings` (GNOME) and `dconf`, but each desktop environment
# (GNOME, KDE, XFCE, …) has its own.
#
# Apply GNOME settings only if the session is running under GNOME.
# Users on other DEs can add their own `~/.bash.local` tweaks.

if [ -n "${XDG_CURRENT_DESKTOP:-}" ] && \
    printf "%s" "$XDG_CURRENT_DESKTOP" | grep -qi "gnome"; then
    ./gnome.sh
else
    print_warning "Skipping desktop preferences: not running GNOME ($XDG_CURRENT_DESKTOP)"
fi

./terminal.sh
./input.sh
