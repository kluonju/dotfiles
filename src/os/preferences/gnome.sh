#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Apply GNOME settings via `gsettings`. These mirror the kinds of
# tweaks the macOS preferences apply (24-hour clock, show file
# extensions, etc.) but using GNOME's schema.

print_in_purple "\n   GNOME\n\n"

gsettings_set() {
    local -r SCHEMA="$1"
    local -r KEY="$2"
    local -r VALUE="$3"

    if ! command -v gsettings &> /dev/null; then
        print_warning "gsettings (not installed)"
        return 1
    fi

    execute \
        "gsettings set '$SCHEMA' '$KEY' '$VALUE'" \
        "Set '$SCHEMA/$KEY'"
}

# 24-hour time.

gsettings_set "org.gnome.desktop.interface" "clock-show-seconds" "true"

# Show hidden files in the file manager.

gsettings_set "org.gnome.nautilus.preferences" "show-hidden-files" "true"

# Show file extensions.

gsettings_set "org.gnome.nautilus.preferences" "show-create-link"  "true"

# Don't show image thumbnails for files larger than 100 MB.

gsettings_set "org.gnome.nautilus.preferences" "thumbnail-limit" "104857600"
