#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Install one or more Debian packages with `apt-get`.
#
# $1: human-readable label (e.g. "git", "vim", "Chromium")
# $2: package name(s) — space separated
# $3 (optional): "--skip-update" to skip `apt-get update` first

apt_install() {
    local -r LABEL="$1"
    local -r PACKAGES="$2"
    local -r FLAGS="$3"

    if [ -z "$PACKAGES" ]; then
        print_error "$LABEL (no package name provided)"
        return 1
    fi

    # Refresh the package index on the first call.
    if [ "${APT_UPDATED:-0}" -eq 0 ] && [[ "$FLAGS" != *--skip-update* ]]; then
        execute \
            "sudo apt-get update -y" \
            "Update package index"
        APT_UPDATED=1
    fi

    execute \
        "sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends $PACKAGES" \
        "$LABEL"
}
