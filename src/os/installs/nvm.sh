#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_nvm() {
    execute \
        "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.8/install.sh | bash" \
        "Install nvm"
}

install_node() {
    # Install Node.js 26 via nvm and set it as the default.
    #
    # Source `~/.nvm/nvm.sh` (added by the nvm installer to
    # `~/.bashrc`) so nvm is available in this shell, then install
    # Node 26 and alias it as the default.

    execute \
        ". \"\$HOME/.nvm/nvm.sh\" \
            && nvm install 26 \
            && nvm alias default 26 \
            && node -v" \
        "Install Node.js 26"
}

install_corepack() {
    # `corepack` ships with Node.js 16+, but installing it explicitly
    # with the npm we just installed makes it a no-op.

    execute \
        ". \"\$HOME/.nvm/nvm.sh\" \
            && npm install -g corepack \
            && corepack enable pnpm \
            && pnpm -v" \
        "Install corepack and enable pnpm"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {
    print_in_purple "\n   nvm + Node.js + pnpm\n\n"

    install_nvm
    install_node
    install_corepack
}

main
