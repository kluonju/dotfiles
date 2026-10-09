#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   TeX Live\n\n"

# `texlive-full` pulls in the entire TeX Live distribution (every
# package, every language). It's a ~5–7 GB download, but it's the
# "install everything" choice and avoids the rabbit hole of figuring
# out which sub-packages a given document needs.

apt_install "TeX Live (full)" "texlive-full" "--skip-update"
