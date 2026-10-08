#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Miscellaneous Tools\n\n"

apt_install "eyeD3"      "eyed3 python3-eyed3" "--skip-update"
apt_install "pdfcpu"     "pdfcpu"              "--skip-update"
apt_install "ShellCheck" "shellcheck"          "--skip-update"
apt_install "Yarn"       "yarn"                "--skip-update"

# The following tools are Homebrew-only and have no apt equivalent.
# Listed here for parity with the macOS install script so reviewers
# know why they're absent.

print_warning "Mole      (install from https://github.com/tw93/mole)"
print_warning "OpenCode  (see https://opencode.ai)"
