#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Bash\n\n"

# Ubuntu ships a recent Bash by default. Only install `bash-completion`,
# the one piece that isn't preinstalled everywhere.

apt_install "Bash Completion" "bash-completion" "--skip-update"
