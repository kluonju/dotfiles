#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Keyboard/input settings. The macOS preferences apply Apple-specific
# keyboard shortcuts and "press and hold" behaviour. Here we just make
# sure the standard readline defaults the dotfiles ship in
# `~/.inputrc` actually take effect.

print_in_purple "\n   Input\n\n"

# Ensure ~/.inputrc gets sourced — bash does this automatically on
# startup, but we still want to remind users it's there.

if [ ! -e "$HOME/.inputrc" ]; then
    print_warning "~/.inputrc is not symlinked (run the setup script)"
fi
