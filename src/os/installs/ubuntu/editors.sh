#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" \
    && . "../../utils.sh" \
    && . "./utils.sh"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

print_in_purple "\n   Visual Studio Code\n\n"

# VSCodium is not in the default Ubuntu repos. Add the upstream
# repository from vscodium.com (matches what the macOS install did,
# just via apt instead of brew).

CODIUM_KEYRING="/usr/share/keyrings/vscodium-archive-keyring.gpg"
CODIUM_LIST="/etc/apt/sources.list.d/vscodium.list"

if [ ! -f "$CODIUM_LIST" ]; then
    execute \
        "curl -fsSL https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
            | sudo gpg --dearmor --yes --output '$CODIUM_KEYRING'" \
        "Add VSCodium GPG key"

    execute \
        "echo 'deb [signed-by=$CODIUM_KEYRING] https://download.vscodium.com/debs vscodium main' \
            | sudo tee '$CODIUM_LIST'" \
        "Add VSCodium apt repository"

    execute \
        "sudo apt-get update -y" \
        "Update package index"
fi

apt_install "VSCodium" "codium" "--skip-update"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

printf "\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Install VSCodium extensions (if any).

install_plugin() {
    execute \
        "codium --install-extension $2 --force" \
        "$1 extension"
}

install_plugin "EditorConfig" "EditorConfig.EditorConfig"
install_plugin "File Icons"   "vscode-icons-team.vscode-icons"
install_plugin "MarkdownLint" "DavidAnson.vscode-markdownlint"
install_plugin "Vim"          "vscodevim.vim"
