#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# macOS's `Solarized Dark.terminal` is an Apple-specific bundle; on
# GNOME we point `org.gnome.Terminal.ProfilesList` at a sensible
# default via gsettings. Print a hint for users who want the full
# Solarized scheme.

print_in_purple "\n   Terminal\n\n"

if command -v gsettings &> /dev/null && \
   printf "%s" "${XDG_CURRENT_DESKTOP:-}" | grep -qi "gnome"; then
    print_warning "Install Solarized for GNOME Terminal from gnome-terminal-solarized"
fi
