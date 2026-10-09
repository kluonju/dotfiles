#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Intel oneAPI toolkit locations.
#
# The current (2026.1) Intel APT install instructions use:
#
#   https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
#   https://apt.repos.intel.com/oneapi all main
#   apt install intel-oneapi-toolkit
#
# Earlier guides used split packages like `intel-oneapi-basekit` /
# `intel-oneapi-hpckit`, or referenced an `oneapi-all` repo path
# that now returns 403. Intel consolidated those into the single
# `intel-oneapi-toolkit` meta-package on the `oneapi` repo.

ONEAPI_REPO_URL="https://apt.repos.intel.com/oneapi"
ONEAPI_KEY_URL="https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB"
ONEAPI_KEYRING="/usr/share/keyrings/oneapi-archive-keyring.gpg"
ONEAPI_LIST="/etc/apt/sources.list.d/oneAPI.list"

# Module system: environment-modules reads `$MODULEPATH`. We point it
# at oneAPI's bundled modulefiles and register the init in `~/.bashrc`
# so `module load …` works in interactive shells. Intel also ships
# split module trees at `basekit/latest/modulefiles` and
# `hpckit/latest/modulefiles` for finer-grained `module load`.

ONEAPI_BASHRC_INIT='
# Load Intel oneAPI modules (added by dotfiles setup).
if [ -f /usr/share/modules/init/bash ]; then
    . /usr/share/modules/init/bash
    export MODULEPATH="/opt/intel/oneapi/modulefiles:/opt/intel/oneapi/basekit/latest/modulefiles:/opt/intel/oneapi/hpckit/latest/modulefiles:$MODULEPATH"
fi
'

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

add_apt_repo() {
    # Disable any stale Intel oneAPI source files. Older dotfiles
    # versions created files under different names (e.g.
    # `intel-oneapi.list`) pointing at the now-defunct
    # `oneapi-all` URL, and apt fails the whole update if even
    # one of them is broken. Move them aside so apt ignores them.

    local stale=0
    local f=""

    if [ -d /etc/apt/sources.list.d ]; then
        for f in /etc/apt/sources.list.d/*; do
            [ -f "$f" ] || continue
            if grep -qE 'apt\.repos\.intel\.com/(oneapi|oneapi-all)' "$f" \
                && ! grep -qE "^deb .* $ONEAPI_REPO_URL( |$)" "$f"; then
                print_warning "Disabling stale Intel oneAPI list: $f"
                sudo mv "$f" "$f.disabled"
                stale=1
            fi
        done
    fi

    # Skip if the canonical list file already exists *and* points
    # at the current repo URL.

    if [ "$stale" -eq 0 ] \
        && [ -f "$ONEAPI_LIST" ] \
        && grep -qE "^deb .* $ONEAPI_REPO_URL( |$)" "$ONEAPI_LIST"; then
        print_success "oneAPI apt repository (already configured)"
        return 0
    fi

    # Fetch the signing key into the system keyring.

    execute \
        "curl -fsSL '$ONEAPI_KEY_URL' \
            | sudo gpg --dearmor --yes --output '$ONEAPI_KEYRING'" \
        "Add oneAPI GPG key"

    # Add the apt source list, signed by the new keyring.

    execute \
        "echo 'deb [signed-by=$ONEAPI_KEYRING arch=amd64] $ONEAPI_REPO_URL all main' \
            | sudo tee '$ONEAPI_LIST'" \
        "Add oneAPI apt repository"

    execute \
        "sudo apt-get update -y" \
        "Update package index"
}

install_toolkit() {
    # Intel now ships a single `intel-oneapi-toolkit` meta-package
    # containing both the Base and HPC kits. Earlier guides listed
    # `intel-oneapi-basekit` / `intel-oneapi-hpckit` as separate
    # packages; those names no longer exist on the `oneapi` repo.

    apt_install "Intel oneAPI Toolkit" "intel-oneapi-toolkit"
}

install_module_system() {
    # `environment-modules` is the de facto module system on Linux.
    # oneAPI ships its own modulefiles; combining the two gives you
    # `module load intel-oneapi-mkl/2024.2` etc.

    apt_install "environment-modules" "environment-modules"
}

register_module_init() {
    # Append a small block to `~/.bashrc` (via `update_local_shell_configs`,
    # which appends once and reloads) so the module system is available
    # in interactive shells.

    update_local_shell_configs "$ONEAPI_BASHRC_INIT"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {
    print_in_purple "\n   Intel oneAPI\n\n"

    add_apt_repo
    install_module_system

    # The consolidated Intel oneAPI toolkit. ~10 GB on disk; comment
    # out this line if you only need a small subset of the tools
    # (you can install individual component packages, e.g.
    # `intel-oneapi-compiler-dpcpp-cpp`, instead).

    install_toolkit

    register_module_init
}

main
