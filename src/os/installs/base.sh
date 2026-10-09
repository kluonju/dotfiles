#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Base packages\n\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Build tools and friends many of the other installers rely on.

apt_install "build-essential"       "build-essential"
apt_install "curl"                  "curl"               "--skip-update"
apt_install "git"                   "git"                "--skip-update"
apt_install "ca-certificates"       "ca-certificates"    "--skip-update"
apt_install "gnupg"                 "gnupg"              "--skip-update"
apt_install "wget"                  "wget"               "--skip-update"
apt_install "unzip"                 "unzip"              "--skip-update"
apt_install "zip"                   "zip"                "--skip-update"
apt_install "file"                  "file"               "--skip-update"
apt_install "less"                  "less"               "--skip-update"
apt_install "Software Properties"   "software-properties-common" "--skip-update"
apt_install "APT HTTPS transport"   "apt-transport-https"        "--skip-update"
