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
        printf "Sorry, this script is intended only for Ubuntu %s+" "$MINIMUM_UBUNTU_VERSION"
        return 1
    fi

    # shellcheck disable=SC1091
    . /etc/os-release

    if [ "${ID:-}" != "ubuntu" ]; then
        printf "Sorry, this script is intended only for Ubuntu %s+" "$MINIMUM_UBUNTU_VERSION"
        return 1
    fi

    os_version="${VERSION_ID:-}"

    if is_supported_version "$os_version" "$MINIMUM_UBUNTU_VERSION"; then
        return 0
    fi

    printf "Sorry, this script is intended only for Ubuntu %s+" "$MINIMUM_UBUNTU_VERSION"
    return 1
}

# ----------------------------------------------------------------------
# | Main                                                               |
# ----------------------------------------------------------------------

main() {
    # Ensure that the following actions
    # are made relative to this file's path.

    cd "$(dirname "${BASH_SOURCE[0]}")" \
        || exit 1

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Load utils

    if [ -x "utils.sh" ]; then
        . "utils.sh" || exit 1
    else
        download_utils || exit 1
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

    ./installs/main.sh

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    ./preferences/main.sh

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    if ! $skipQuestions; then
        ./restart.sh
    fi
}

main "$@"
