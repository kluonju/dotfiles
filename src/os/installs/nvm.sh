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

    # If a previous run created $NVM_DIR but didn't finish writing
    # nvm.sh (e.g. interrupted mid-install, or `$HOME` was wrong),
    # the installer's `git fetch` against a broken tree can leave
    # the directory in a half-installed state. Wipe it so the
    # installer's "fresh clone" path is taken.

    if [ -d "$NVM_DIR" ] && [ ! -s "$NVM_DIR/nvm.sh" ]; then
        print_warning "Removing partial nvm install at $NVM_DIR"
        rm -rf "$NVM_DIR"
    fi

    # Pin NVM_DIR in the installer subshell. Without this, the
    # installer reads `NVM_DIR` from the inherited env (or, failing
    # that, `$HOME/.nvm`). If a prior tool exported NVM_DIR to a
    # different path — or if `$HOME` in the subshell differs from
    # the user's actual home — nvm.sh ends up somewhere other
    # than `$HOME/.nvm`, and the follow-up `\. "$HOME/.nvm/nvm.sh"`
    # in `install_node` fails with "no such file or directory".

    # Capture the installer's output so we can show it on failure
    # — the `execute` helper discards stdout by default.

    local -r NVM_LOG="$(mktemp /tmp/nvm-install.XXXXX.log)"

    execute \
        "NVM_DIR='$NVM_DIR' \
            curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh \
                | NVM_DIR='$NVM_DIR' bash > '$NVM_LOG' 2>&1" \
        "Install nvm"

    # Sanity check: the installer should have created
    # `$NVM_DIR/nvm.sh`. If not, surface the captured log so the
    # user can see what the installer actually did.

    if [ ! -s "$NVM_DIR/nvm.sh" ]; then
        printf "\n%s\n" \
            "nvm install reported success, but $NVM_DIR/nvm.sh is missing."
        printf "%s\n" \
            "If \$HOME was set to a different directory when this script ran,"
        printf "%s\n\n" \
            "nvm installed elsewhere. Re-run as the user who owns \$HOME."
        printf "%s\n" \
            "Installer output (truncated to last 20 lines):"
        tail -n 20 "$NVM_LOG" 2>/dev/null | sed 's/^/  /'
        printf "\n%s\n" \
            "Searching for an existing nvm install on disk:"
        command find / -name 'nvm.sh' 2>/dev/null \
            | grep -v '/proc/' \
            | head -n 10 \
            | sed 's/^/  /'
        rm -f "$NVM_LOG"
        return 1
    fi

    rm -f "$NVM_LOG"
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
