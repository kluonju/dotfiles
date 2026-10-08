#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Make sure apt has an up-to-date package list before
# anything else starts installing.

ask_for_sudo

./base.sh

reload_local_shell_configs
./bash.sh
./git.sh
./volta.sh
./browsers.sh
./compression_tools.sh
./gpg.sh
./image_tools.sh
./misc.sh
./misc_tools.sh
./npm.sh
./tmux.sh
./video_tools.sh
./vim.sh
./shell_tools.sh
