#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Vim\n\n"

# `vim` ships with Ubuntu, but minimal builds drop features
# (`+clipboard`, `+python3`). Install the fuller `vim-gtk3` build which
# has clipboard + GUI libs, falling back to `vim-nox` for headless.

if apt-cache show vim-gtk3 &> /dev/null; then
    apt_install "Vim" "vim-gtk3" "--skip-update"
else
    apt_install "Vim" "vim-nox" "--skip-update"
fi
