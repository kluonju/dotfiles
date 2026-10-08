#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Video Tools\n\n"

# AtomicParsley is not in the default Ubuntu repos. Skip if missing.

if apt-cache show atomicparsley &> /dev/null; then
    apt_install "AtomicParsley" "atomicparsley" "--skip-update"
else
    print_warning "AtomicParsley (not in apt repos)"
fi

apt_install "FFmpeg" "ffmpeg" "--skip-update"
