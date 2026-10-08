#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Browsers\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

printf "\n"

# Chromium on Ubuntu is most easily installed via `snap`, which Ubuntu
# ships pre-installed (and which is what `snapd` does not yet need).

if cmd_exists "snap"; then
    execute \
        "sudo snap install chromium" \
        "Chromium"
else
    apt_install "Chromium" "chromium-browser" "--skip-update"
fi

apt_install "Firefox" "firefox" "--skip-update"
