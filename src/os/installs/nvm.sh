#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

NVM_VERSION="v0.40.8"
NVM_DIR="$HOME/.nvm"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_nvm() {
    # nvm's installer is idempotent — it skips an existing install.
    # Check for the install file directly so we don't re-run.

    if [ -s "$NVM_DIR/nvm.sh" ]; then
        print_success "nvm (already installed)"
        return 0
    fi

    execute \
        "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | bash" \
        "Install nvm"

    # Sanity check: the installer should have created
    # `$NVM_DIR/nvm.sh`. If not, something's off about the
    # environment (e.g. `$HOME` differs between this script and
    # the curl|bash subshell).

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
    # The official nvm install instructions:
    #
    #   # Download and install nvm:
    #   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.8/install.sh | bash
    #   # in lieu of restarting the shell
    #   \. "$HOME/.nvm/nvm.sh"
    #   # Download and install Node.js:
    #   nvm install 26
    #   # Verify the Node.js version:
    #   node -v # Should print "v26.11.1".
    #   # Verify npm version:
    #   npm -v # Should print "11.20.0".
    #
    # The whole sequence is wrapped in a single `execute` so the
    # shell state (the sourced `nvm.sh`) is preserved across the
    # chained commands.

    execute \
        ". \"\$HOME/.nvm/nvm.sh\" \
            && nvm install 26 \
            && node -v \
            && npm -v" \
        "Install Node.js 26"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {
    print_in_purple "\n   nvm + Node.js\n\n"

    install_nvm
    install_node
}

main
