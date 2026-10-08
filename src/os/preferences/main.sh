#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n • Preferences\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Apply desktop settings. GNOME is detected via `XDG_CURRENT_DESKTOP`;
# users on other DEs (KDE, XFCE, …) can add their own tweaks to
# `~/.bash.local` instead.

if [ -n "${XDG_CURRENT_DESKTOP:-}" ] && \
    printf "%s" "$XDG_CURRENT_DESKTOP" | grep -qi "gnome"; then
    ./gnome.sh
else
    print_warning "Skipping desktop preferences: not running GNOME (XDG_CURRENT_DESKTOP=$XDG_CURRENT_DESKTOP)"
fi

./terminal.sh
./input.sh
