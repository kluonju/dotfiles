#!/bin/bash

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Heavy installer.
#
# `./setup.sh` deliberately skips installs so it can finish in
# seconds — it only sets up symlinks, local config files, and
# desktop preferences. Run this script separately when you want
# the actual packages:
#
#   ./install.sh
#
# It runs every install script under `src/os/installs/` (base
# packages, nvm + Node, rustup, Intel oneAPI, TeX Live, …) and
# is idempotent: each underlying script checks for an existing
# install before doing anything.

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

declare skipQuestions=false

# ----------------------------------------------------------------------
# | Helper Functions                                                   |
# ----------------------------------------------------------------------

download_utils() {
    local tmpFile=""

    tmpFile="$(mktemp /tmp/XXXXX)"

    if command -v "curl" &> /dev/null; then
        curl \
            --location \
            --silent \
            --show-error \
            --output "$tmpFile" \
            "https://raw.githubusercontent.com/kluonju/dotfiles/ubuntu/src/os/utils.sh" \
                &> /dev/null \
            && . "$tmpFile" \
            && rm -rf "$tmpFile" \
            && return 0
    elif command -v "wget" &> /dev/null; then
        wget \
            --quiet \
            --output-document="$tmpFile" \
            "https://raw.githubusercontent.com/kluonju/dotfiles/ubuntu/src/os/utils.sh" \
                &> /dev/null \
            && . "$tmpFile" \
            && rm -rf "$tmpFile" \
            && return 0
    fi

    return 1
}

verify_os() {
    local -r MINIMUM_UBUNTU_VERSION="26.04"

    if ! [ -r /etc/os-release ]; then
        printf "Sorry, this script is intended only for Ubuntu %s+\n" \
            "$MINIMUM_UBUNTU_VERSION"
        return 1
    fi

    # shellcheck disable=SC1091
    . /etc/os-release

    if [ "${ID:-}" != "ubuntu" ]; then
        printf "Sorry, this script is intended only for Ubuntu %s+\n" \
            "$MINIMUM_UBUNTU_VERSION"
        return 1
    fi

    if ! declare -F is_supported_version > /dev/null; then
        printf "Internal error: utils.sh was not sourced. Aborting.\n" >&2
        return 2
    fi

    if is_supported_version "${VERSION_ID:-}" "$MINIMUM_UBUNTU_VERSION"; then
        return 0
    fi

    printf "Sorry, this script is intended only for Ubuntu %s+\n" \
        "$MINIMUM_UBUNTU_VERSION"
    return 1
}

# ----------------------------------------------------------------------
# | Main                                                               |
# ----------------------------------------------------------------------

main() {
    cd "$(dirname "${BASH_SOURCE[0]}")/src/os/installs" \
        || exit 1

    # Load utils.

    if [ -x "./utils.sh" ] && [ -x "../utils.sh" ]; then
        . "../utils.sh" || {
            printf "Failed to source ../utils.sh\n" >&2
            exit 1
        }
        . "./utils.sh" || {
            printf "Failed to source ./utils.sh\n" >&2
            exit 1
        }
    else
        download_utils || {
            printf "Failed to source utils.sh (no local copy and network fetch failed)\n" >&2
            exit 1
        }
    fi

    if ! declare -F is_supported_version > /dev/null; then
        printf "Sourced utils.sh but is_supported_version is missing.\n" >&2
        printf "Check that src/os/utils.sh defines it.\n" >&2
        exit 1
    fi

    # OS gate.

    verify_os \
        || exit 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    skip_questions "$@" \
        && skipQuestions=true

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    ask_for_sudo

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Run each install script. The order is the same as the
    # original `./installs/main.sh` (base → nvm → rustup → oneAPI
    # → texlive) so cross-script dependencies (e.g. `curl` from
    # base.sh before nvm.sh) keep working.

    ./base.sh

    reload_local_shell_configs
    ./bash.sh
    ./git.sh
    ./nvm.sh
    ./browsers.sh
    ./compression_tools.sh
    ./gpg.sh
    ./image_tools.sh
    ./misc.sh
    ./misc_tools.sh
    ./tmux.sh
    ./video_tools.sh
    ./vim.sh
    ./shell_tools.sh
    ./tex.sh
    ./intel_oneapi.sh
    ./rust.sh

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if ! $skipQuestions; then
        printf "\n%s\n" "Restart your shell or run 'source ~/.bash.local' to pick up new env (cargo, module, …)."
    fi
}

main "$@"
