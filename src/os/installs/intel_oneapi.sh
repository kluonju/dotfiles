#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Intel oneAPI toolkit locations.
#
# The current (2024+) Intel APT install instructions use:
#
#   https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
#   https://apt.repos.intel.com/oneapi all main
#
# The earlier `oneapi-all/KEYS` endpoint now returns 403. If you
# are behind a proxy, set `http_proxy` / `https_proxy` in your
# environment so the `apt` client can reach the repo.

ONEAPI_REPO_URL="https://apt.repos.intel.com/oneapi"
ONEAPI_KEY_URL="https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB"
ONEAPI_KEYRING="/usr/share/keyrings/oneapi-archive-keyring.gpg"
ONEAPI_LIST="/etc/apt/sources.list.d/oneAPI.list"

# Module system: environment-modules reads `$MODULEPATH`. We point it
# at oneAPI's bundled modulefiles and register the init in `~/.bashrc`
# so `module load …` works in interactive shells.

ONEAPI_MODULE_BASE="/opt/intel/oneapi/modulefiles"
ONEAPI_BASHRC_INIT='
# Load Intel oneAPI modules (added by dotfiles setup).
if [ -f /usr/share/modules/init/bash ]; then
    . /usr/share/modules/init/bash
    export MODULEPATH="/opt/intel/oneapi/modulefiles:/opt/intel/oneapi/basekit/latest/modulefiles:/opt/intel/oneapi/hpckit/latest/modulefiles:$MODULEPATH"
fi
'

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

add_apt_repo() {
    # Skip if the repo file already exists *and* points at the
    # current repo URL. The earlier `oneapi-all/KEYS` endpoint
    # now returns 403; if a previous run created a list pointing
    # at that (or any other) stale URL, replace it.

    if [ -f "$ONEAPI_LIST" ] && grep -qF "$ONEAPI_REPO_URL" "$ONEAPI_LIST"; then
        print_success "oneAPI apt repository (already configured)"
        return 0
    fi

    if [ -f "$ONEAPI_LIST" ]; then
        print_warning "Replacing stale oneAPI list at $ONEAPI_LIST"
        sudo rm -f "$ONEAPI_LIST"
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

install_basekit() {
    # Base Toolkit: compilers (icx/ifx), MKL, MPI, IPP, TBB, …
    # ~4 GB on disk.

    apt_install "Intel oneAPI Base Toolkit" "intel-oneapi-basekit"
}

install_hpckit() {
    # HPC Toolkit: classic Intel compilers (icc/ifort) and MPI
    # variants, plus analysis tools. ~6 GB on disk. Comment this line
    # out if you only need Base.

    apt_install "Intel oneAPI HPC Toolkit" "intel-oneapi-hpckit"
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

    # The two toolkits are separate apt packages. Each is a large
    # download — comment out the one you don't want.

    install_basekit
    install_hpckit

    register_module_init
}

main
