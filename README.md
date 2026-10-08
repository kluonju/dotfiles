# Dotfiles

Base dotfiles for Ubuntu 26.04+. For local settings that shouldn't
live under version control, drop them in the `*.local` files
documented under [Customize](#customize).

## Table of Contents

* [🔧 Setup](#setup)
* [💄 Customize](#customize)
  * [🐚 `~/.bash.local`](#bashlocal)
  * [🔁 `~/.gitconfig.local`](#gitconfiglocal)
  * [⌨️  `~/.vimrc.local`](#vimrclocal)
* [↕️  Update](#update)
* [📑 License](#license)

## Setup

Run the setup script from a local checkout:

```bash
git clone git@github.com:kluonju/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles/src/os
./setup.sh
```

Pass `-y` to skip the interactive prompts:

```bash
./setup.sh -y
```

> [!CAUTION]
> __DO NOT__ run the setup script if you do not fully understand
> [what it does][setup]. Seriously, __DON'T__!

The setup process will:

* [Symlink][symlink] the [Git], [shell], [tmux], and [Vim] files into `~/`.
* Create `~/.bash.local`, `~/.gitconfig.local`, `~/.vimrc.local` if missing.
* Install applications and command-line tools for [Ubuntu][install ubuntu].
* Set [Ubuntu preferences][preferences ubuntu] (GNOME `gsettings`).
* Install the [Vim plugins][vim plugins].

## Customize

The dotfiles can be extended for local needs via these files (loaded
after the version-controlled ones, so they can override or extend):

### `~/.bash.local`

Automatically sourced after the other [Bash related files][shell]. Use
it for `PATH` additions, local aliases, environment variables, etc.

```bash
#!/bin/bash

PATH="$HOME/projects/dotfiles/src/bin/:$PATH"
export PATH

alias g="git"
```

### `~/.gitconfig.local`

Automatically included after `~/.gitconfig`. Use it for sensitive
information such as Git user credentials:

```ini
[commit]
    gpgsign = true

[gpg]
    format = ssh

[gpg "ssh"]
    allowedSignersFile = ~/.ssh/allowed_signers

[user]
    name = Your Name
    email = account@example.com
    signingkey = "..."
```

### `~/.vimrc.local`

Automatically sourced after `~/.vimrc`. Use it to override or extend
the Vim settings:

```vim
" Disable arrow keys in insert mode.

inoremap <Down>  <ESC>:echoe "Use j"<CR>
inoremap <Left>  <ESC>:echoe "Use h"<CR>
inoremap <Right> <ESC>:echoe "Use l"<CR>
inoremap <Up>    <ESC>:echoe "Use k"<CR>
```

## Update

Re-run the [setup script][setup] any time you change a file. It
re-creates the symlinks and skips already-installed packages.

## License

The code is available under the [MIT license][license].

<!-- Link labels: -->

[Git]: src/git
[install ubuntu]: src/os/installs
[license]: LICENSE.txt
[preferences ubuntu]: src/os/preferences
[setup]: src/os/setup.sh
[shell]: src/shell
[symlink]: src/os/create_symbolic_links.sh
[tmux]: src/tmux
[vim plugins]: src/vim/vim/pack/minpac/start
[Vim]: src/vim
