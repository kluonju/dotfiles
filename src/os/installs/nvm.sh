#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

NVM_VERSION="v0.40.8"
NVM_DIR="$HOME/.nvm"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_nvm() {
    # nvm's installer is idempotent — it skips an existing install.
    # We use `command -v nvm` to detect an existing install (which
    # only works in shells that have already sourced `nvm.sh`), but
    # the more reliable check is whether the install directory
    # exists.

    if [ -s "$NVM_DIR/nvm.sh" ]; then
        print_success "nvm (already installed)"
        return 0
    fi

    execute \
        "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | bash" \
        "Install nvm"

    if [ ! -s "$NVM_DIR/nvm.sh" ]; then
        printf "\n%s\n\n" \
            "nvm install reported success, but $NVM_DIR/nvm.sh is missing."
        printf "%s\n" \
            "If \$HOME was set to a different directory when this script ran,"
        printf "%s\n" \
            "nvm installed elsewhere. Re-run as the user who owns \$HOME."
        return 1
    fi
}

install_node() {
    # Source nvm in a fresh login shell (which loads `~/.bashrc`,
    # where nvm's installer adds its own `[ -s "$NVM_DIR/nvm.sh" ]
    # && \. …` line). Use `bash -lc` so `.bashrc` actually runs
    # in non-interactive contexts.

    execute \
        "bash -lc '\
            nvm install 26 && \
            nvm alias default 26 && \
            node -v'" \
        "Install Node.js 26"
}

install_corepack() {
    execute \
        "bash -lc '\
            npm install -g corepack && \
            corepack enable pnpm && \
            pnpm -v'" \
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
