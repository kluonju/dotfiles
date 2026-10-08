#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   GPG\n\n"

apt_install "GPG"       "gpg"                 "--skip-update"
apt_install "Pinentry"  "pinentry-curses"     "--skip-update"
