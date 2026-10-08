#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Browsers\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

printf "\n"

# Use apt directly — no snap. On Ubuntu the `chromium-browser` deb
# package pulls in the same Chromium release that the snap would, just
# without the snapd dependency.

apt_install "Chromium" "chromium-browser" "--skip-update"

apt_install "Firefox" "firefox" "--skip-update"
