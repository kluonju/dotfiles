#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Intel oneAPI toolkit locations.

ONEAPI_REPO_URL="https://apt.repos.intel.com/oneapi-all"
ONEAPI_KEYRING="/usr/share/keyrings/intel-oneapi-archive-keyring.gpg"
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
    # Skip if the repo file already exists.

    if [ -f "$ONEAPI_LIST" ]; then
        print_success "oneAPI apt repository (already configured)"
        return 0
    fi

    # Fetch the signing key into the system keyring.

    execute \
        "curl -fsSL '$ONEAPI_REPO_URL/KEYS' \
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
