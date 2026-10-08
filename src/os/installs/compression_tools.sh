#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Compression Tools\n\n"

apt_install "Brotli" "brotli"      "--skip-update"

# `zopfli` is in the universe repo. Make sure it's enabled first by
# the base install, otherwise apt_install will fail with "not found".

if apt-cache show zopfli &> /dev/null; then
    apt_install "Zopfli" "zopfli"  "--skip-update"
else
    print_warning "Zopfli (the 'zopfli' package is not in your apt repos)"
fi
