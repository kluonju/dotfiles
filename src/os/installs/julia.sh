#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Julia toolchain locations.
#
# juliaup is the official version manager for Julia. It installs
# the `julia` launcher plus a `juliaup` CLI, and places everything
# under the user's home directory:
#
#   ~/.juliaup/    — juliaup itself + completion scripts
#   ~/.julia/      — depot (versions, registry, environments)
#
# We pass `--add-to-path=no` to the installer so it does not
# touch any shell profile; instead, we register the juliaup
# env in `~/.bash.local` (via `update_local_shell_configs`) so
# `~/.juliaup/bin` is on PATH in interactive shells.
#
# Tsinghua TUNA mirrors juliaup's binary releases. The default
# `JULIAUP_SERVER` is `https://julialang-s3.julialang.org`, which
# is slow or blocked from mainland China. The TUNA mirror is
# picked up via the `JULIAUP_SERVER` env var below.
#
# USTC mirrors the Julia package registry (used by `Pkg.add`,
# `Pkg.update`, precompilation downloads, …) at
# `https://mirrors.ustc.edu.cn/julia`. That is the standard
# Chinese mirror for `JULIA_PKG_SERVER`.
#
# Guides:
#   https://mirrors.tuna.tsinghua.edu.cn/help/julia-releases/
#   https://mirrors.ustc.edu.cn/help/julia.html

JULIAUP_INSTALL_URL="https://install.julialang.org"
JULIAUP_INIT_FLAGS="-y --default-channel release --add-to-path=no --background-selfupdate=0 --startup-selfupdate=0"
JULIAUP_SERVER="https://mirrors.tuna.tsinghua.edu.cn/julia-releases"
JULIA_PKG_SERVER="https://mirrors.ustc.edu.cn/julia"
JULIAUP_BIN_DIR="$HOME/.juliaup/bin"
JULIAUP_BIN="$JULIAUP_BIN_DIR/juliaup"
JULIA_BIN="$JULIAUP_BIN_DIR/julia"

JULIA_ENV_INIT='
# Load Julia toolchain env (added by dotfiles setup).
# juliaup is installed with --add-to-path=no, so ~/.juliaup/bin
# is not on PATH in new shells unless we add it here.
export PATH="$HOME/.juliaup/bin:$PATH"
# Use Tsinghua TUNA mirror for juliaup binary downloads.
export JULIAUP_SERVER="https://mirrors.tuna.tsinghua.edu.cn/julia-releases"
# Use USTC mirror for the Julia package registry.
export JULIA_PKG_SERVER="https://mirrors.ustc.edu.cn/julia"
'

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_build_prereqs() {
    # juliaup's installer is a `curl | sh` pipe, so `curl` and
    # `ca-certificates` are required. `build-essential` is needed
    # for compiling some Julia packages from source.

    apt_install "Julia build prerequisites" "curl ca-certificates build-essential"
}

install_juliaup() {
    # juliaup's installer is idempotent — it skips an existing
    # install. Check for the juliaup binary directly so we don't
    # re-run.

    if [ -x "$JULIAUP_BIN" ]; then
        print_success "juliaup (already installed)"
        return 0
    fi

    # The official install instructions are:
    #
    #   curl -fsSL https://install.julialang.org | sh
    #
    # That is interactive. We append `$JULIAUP_INIT_FLAGS` so the
    # installer is non-interactive and matches the rustup-style
    # "default toolchain, no shell-profile modification" pattern.
    #
    # `JULIAUP_SERVER` is exported into the curl|sh subshell so
    # the initial binary download goes through the TUNA mirror.

    execute \
        "JULIAUP_SERVER='$JULIAUP_SERVER' \
            curl --proto '=https' --tlsv1.2 -fsSL '$JULIAUP_INSTALL_URL' \
            | sh -s -- $JULIAUP_INIT_FLAGS" \
        "Install juliaup (TUNA mirror)"

    # Sanity check: the installer should have placed `juliaup` at
    # `~/.juliaup/bin/juliaup`. If not, something's off about the
    # environment (e.g. `$HOME` differs between this script and
    # the curl|sh subshell).

    if [ ! -x "$JULIAUP_BIN" ]; then
        printf "\n%s\n\n" \
            "juliaup install reported success, but $JULIAUP_BIN is missing."
        printf "%s\n" \
            "If \$HOME was set to a different directory when this script ran,"
        printf "%s\n" \
            "juliaup installed elsewhere. Re-run as the user who owns \$HOME."
        return 1
    fi
}

register_julia_env() {
    # The juliaup installer was invoked with `--add-to-path=no`, so
    # `~/.juliaup/bin` is not on PATH in new shells. Append a
    # small block to `~/.bash.local` (via
    # `update_local_shell_configs`, which appends once and reloads)
    # so the env is loaded in interactive shells.

    update_local_shell_configs "$JULIA_ENV_INIT"
}

verify_install() {
    # The official install instructions verify the install with:
    #
    #   juliaup --version
    #   julia --version
    #
    # The whole sequence is wrapped in a single `execute` so the
    # shell state (the modified PATH / JULIAUP_SERVER /
    # JULIA_PKG_SERVER) is preserved across the chained commands.

    execute \
        "export PATH='$JULIAUP_BIN_DIR:'\"\$PATH\" \
            && export JULIAUP_SERVER='$JULIAUP_SERVER' \
            && export JULIA_PKG_SERVER='$JULIA_PKG_SERVER' \
            && juliaup --version \
            && julia --version" \
        "Verify juliaup + julia"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {
    print_in_purple "\n   Julia\n\n"

    install_build_prereqs
    install_juliaup
    register_julia_env
    verify_install
}

main
