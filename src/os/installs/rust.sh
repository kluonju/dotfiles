#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Rust toolchain locations.
#
# rustup installs everything under the user's home directory:
#
#   ~/.cargo/        — binaries (rustc, cargo, rustup, …) + registry
#   ~/.rustup/       — toolchains and components
#
# We pass `--no-modify-path` to the installer so it does not touch
# any shell profile; instead, we register the Cargo env in
# `~/.bash.local` (via `update_local_shell_configs`) so it is
# available in interactive shells.
#
# Tsinghua TUNA mirrors: rustup's default download host
# (sh.rustup.rs / static.rust-lang.org) is slow or blocked from
# mainland China. The TUNA mirrors publish the same artifacts and
# are picked up via the two env vars below. `RUSTUP_DIST_SERVER`
# redirects toolchain downloads; `RUSTUP_UPDATE_ROOT` redirects the
# `rustup self update` channel. Both are forwarded to the installer
# so the initial install also uses the mirror.
#
# Guide: https://linuxconfig.org/how-to-install-rust-with-rustup-on-ubuntu-26-04

RUSTUP_INSTALL_URL="https://sh.rustup.rs"
RUSTUP_INIT_FLAGS="-y --default-toolchain stable --no-modify-path"
RUSTUP_DIST_SERVER="https://mirrors.tuna.tsinghua.edu.cn/rustup"
RUSTUP_UPDATE_ROOT="https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup"
CARGO_ENV_FILE="$HOME/.cargo/env"
CARGO_BIN_DIR="$HOME/.cargo/bin"
RUSTUP_BIN="$CARGO_BIN_DIR/rustup"
CARGO_CONFIG_FILE="$HOME/.cargo/config.toml"
CARGO_CONFIG_MARKER="# Added by dotfiles setup — switch the default registry"
RUSTUP_ENV_INIT='
# Load Rust toolchain env (added by dotfiles setup).
. "$HOME/.cargo/env"
# Use Tsinghua TUNA mirrors for rustup / toolchain downloads.
export RUSTUP_DIST_SERVER="https://mirrors.tuna.tsinghua.edu.cn/rustup"
export RUSTUP_UPDATE_ROOT="https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup"
'

# Cargo registry mirrors.
#
# `crates.io` itself is reachable from most places, but a domestic
# mirror is dramatically faster from China. The default is `aliyun`
# (sparse protocol — fast and currently maintained). Other mirrors
# (ustc, sjtu, tuna, rustcc) are listed in the config too, so the
# user can switch by editing `$CARGO_CONFIG_FILE` and changing
# `replace-with` to one of the other source names below.
#
# The full block is appended only once (guarded by `$CARGO_CONFIG_MARKER`),
# so re-running the script is a no-op.
#
# The block is written via a quoted heredoc piped to `tee -a`, so
# single quotes and double quotes inside the block are preserved
# verbatim (no shell expansion, no escaping needed).

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

install_build_prereqs() {
    # The Rust compiler needs a C linker and related tools to compile
    # programs. `build-essential` provides GCC, `make`, and the C
    # library headers that Rust's linker requires. `curl` is needed
    # to download the rustup installer.

    apt_install "Rust build prerequisites" "curl build-essential"
}

install_rustup() {
    # rustup's installer is idempotent — it skips an existing install.
    # Check for the rustup binary directly so we don't re-run.

    if [ -x "$RUSTUP_BIN" ]; then
        print_success "rustup (already installed)"
        return 0
    fi

    # The official install instructions are:
    #
    #   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    #
    # That is interactive (it asks the user to pick 1/2/3). We append
    # `$RUSTUP_INIT_FLAGS` so the installer is non-interactive and
    # matches the guide's "press 1" default (stable toolchain, no
    # shell-profile modification).
    #
    # `RUSTUP_DIST_SERVER` / `RUSTUP_UPDATE_ROOT` are exported into
    # the curl|sh subshell so the initial toolchain download and
    # self-update channel both go through the Tsinghua TUNA mirror.

    execute \
        "RUSTUP_DIST_SERVER='$RUSTUP_DIST_SERVER' \
            RUSTUP_UPDATE_ROOT='$RUSTUP_UPDATE_ROOT' \
            curl --proto '=https' --tlsv1.2 -sSf '$RUSTUP_INSTALL_URL' \
            | sh -s -- $RUSTUP_INIT_FLAGS" \
        "Install rustup (stable, TUNA mirror)"

    # Sanity check: the installer should have placed `rustup` at
    # `~/.cargo/bin/rustup`. If not, something's off about the
    # environment (e.g. `$HOME` differs between this script and
    # the curl|bash subshell).

    if [ ! -x "$RUSTUP_BIN" ]; then
        printf "\n%s\n\n" \
            "rustup install reported success, but $RUSTUP_BIN is missing."
        printf "%s\n" \
            "If \$HOME was set to a different directory when this script ran,"
        printf "%s\n" \
            "rustup installed elsewhere. Re-run as the user who owns \$HOME."
        return 1
    fi
}

register_cargo_env() {
    # The rustup installer was invoked with `--no-modify-path`, so
    # `~/.cargo/env` is not sourced in new shells. Append a small
    # block to `~/.bash.local` (via `update_local_shell_configs`,
    # which appends once and reloads) so the env is loaded in
    # interactive shells.

    update_local_shell_configs "$RUSTUP_ENV_INIT"
}

write_cargo_config() {
    # Write `~/.cargo/config.toml` so `cargo` uses a domestic
    # registry mirror instead of crates.io directly. The block is
    # guarded by `$CARGO_CONFIG_MARKER`; if the marker is already
    # present, we treat the config as ours and skip.
    #
    # `~/.cargo/` may not exist yet if rustup was just installed in
    # a previous step but no other cargo command has run — create it
    # first.

    if [ -e "$CARGO_CONFIG_FILE" ] && \
       grep -qF "$CARGO_CONFIG_MARKER" "$CARGO_CONFIG_FILE"; then
        print_success "Cargo registry mirror config (already configured)"
        return 0
    fi

    # The heredoc lives directly in this function (not inside a
    # single double-quoted `execute` arg) so the shell parses it
    # natively. `mkdir` is the only side-effect we want to fold
    # into the same `execute` call so the spinner can show it.
    # `tee -a` is appended so a pre-existing `config.toml` (e.g.
    # the default rustup creates) is left intact and the mirror
    # block is added after it.

    execute \
        "mkdir -p '$HOME/.cargo' \
            && tee -a '$CARGO_CONFIG_FILE' > /dev/null" \
        "Configure Cargo registry mirror" \
        <<CARGO_CONFIG_EOF
$CARGO_CONFIG_MARKER
[source.crates-io]
replace-with = 'aliyun' # replace with the name after [source.*]
# Ali cloud
[source.aliyun]
registry = "sparse+https://mirrors.aliyun.com/crates.io-index/"
# University of Science and Technology of China
[source.ustc]
registry = "https://mirrors.ustc.edu.cn/crates.io-index"
# Shanghai Jiao Tong University
[source.sjtu]
registry = "https://mirrors.sjtug.sjtu.edu.cn/git/crates.io-index/"
# Tsinghua University
[source.tuna]
registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"
# rustcc at Ali cloud
[source.rustcc]
registry = "https://code.aliyun.com/rustcc/crates.io-index.git"
CARGO_CONFIG_EOF
}

verify_install() {
    # The official install instructions verify the install with:
    #
    #   rustc --version
    #   cargo --version
    #
    # The whole sequence is wrapped in a single `execute` so the
    # shell state (the sourced `cargo/env`) is preserved across the
    # chained commands.

    execute \
        ". \"$CARGO_ENV_FILE\" \
            && rustc --version \
            && cargo --version" \
        "Verify rustc + cargo"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

main() {
    print_in_purple "\n   Rust\n\n"

    install_build_prereqs
    install_rustup
    register_cargo_env
    write_cargo_config
    verify_install
}

main
