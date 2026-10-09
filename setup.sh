#!/bin/bash

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

declare skipQuestions=false

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Fetch `utils.sh` over the network when the script was downloaded
# via curl (i.e., not from a local checkout).

declare -r DOTFILES_UTILS_URL="https://raw.githubusercontent.com/kluonju/dotfiles/ubuntu/src/os/utils.sh"

# ----------------------------------------------------------------------
# | Helper Functions                                                   |
# ----------------------------------------------------------------------

download() {
    local url="$1"
    local output="$2"

    if command -v "curl" &> /dev/null; then
        curl \
            --location \
            --silent \
            --show-error \
            --output "$output" \
            "$url" \
                &> /dev/null
        return $?
    elif command -v "wget" &> /dev/null; then
        wget \
            --quiet \
            --output-document="$output" \
            "$url" \
                &> /dev/null
        return $?
    fi

    return 1
}

download_utils() {
    local tmpFile=""

    tmpFile="$(mktemp /tmp/XXXXX)"

    download "$DOTFILES_UTILS_URL" "$tmpFile" \
        && . "$tmpFile" \
        && rm -rf "$tmpFile" \
        && return 0

    return 1
}

verify_os() {
    local -r MINIMUM_UBUNTU_VERSION="26.04"

    local os_version=""

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

    os_version="${VERSION_ID:-}"

    # `is_supported_version` lives in `utils.sh`, which `main` is
    # supposed to source before calling this function. If it's
    # missing here, the source failed earlier — bail with an
    # actionable error rather than letting bash emit a confusing
    # "command not found" line.

    if ! declare -F is_supported_version > /dev/null; then
        printf "Internal error: utils.sh was not sourced. Aborting.\n" >&2
        return 2
    fi

    if is_supported_version "$os_version" "$MINIMUM_UBUNTU_VERSION"; then
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
    # Ensure that the following actions
    # are made relative to this file's path.

    cd "$(dirname "${BASH_SOURCE[0]}")/src/os" \
        || exit 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Load utils

    if [ -x "utils.sh" ]; then
        . "utils.sh" || {
            printf "Failed to source ./utils.sh\n" >&2
            exit 1
        }
    else
        download_utils || {
            printf "Failed to source utils.sh (no local copy and network fetch failed)\n" >&2
            exit 1
        }
    fi

    # `verify_os` (called below) depends on `is_supported_version`
    # from utils.sh. If the source loaded something other than the
    # expected utils.sh, fail here with a clear message instead of
    # letting `verify_os` print a generic "command not found" line.

    if ! declare -F is_supported_version > /dev/null; then
        printf "Sourced utils.sh but is_supported_version is missing.\n" >&2
        printf "Check that src/os/utils.sh defines it.\n" >&2
        exit 1
    fi

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Ensure the OS is supported and
    # it's above the required version.

    verify_os \
        || exit 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    skip_questions "$@" \
        && skipQuestions=true

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    ask_for_sudo

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    ./create_symbolic_links.sh "$@"

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    ./create_local_config_files.sh

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Heavy installs (apt packages, nvm, rustup, oneAPI, TeX) are
    # split out into `./install.sh` so that this script can finish
    # in seconds. Run it separately when you want the packages:
    #
    #   ./install.sh

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    ./preferences/main.sh

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if ! $skipQuestions; then
        ./restart.sh
    fi
}

main "$@"
