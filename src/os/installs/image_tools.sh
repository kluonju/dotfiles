#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Image Tools\n\n"

apt_install "ImageMagick" "imagemagick" "--skip-update"
apt_install "pngquant"    "pngquant"    "--skip-update"

# ImageOptim is macOS-only. On Linux, `jpegoptim`, `optipng`, and
# `pngcrush` are the usual replacements.

apt_install "jpegoptim" "jpegoptim" "--skip-update"
apt_install "optipng"   "optipng"   "--skip-update"
apt_install "pngcrush"  "pngcrush"  "--skip-update"
