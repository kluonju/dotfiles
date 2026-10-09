#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Miscellaneous Tools\n\n"

apt_install "eyeD3"      "eyed3 python3-eyed3" "--skip-update"
apt_install "ShellCheck" "shellcheck"          "--skip-update"
