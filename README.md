# A clean Unix home

Anything *but* clean at this point, as I work my way toward the goal
of having a works-out-of-the-box Unix setup to use and sync on all
my devices.

Installation:

  - Clone repository to location of your choice (${CLONE})

  - Copy ${CLONE}/system/etc/profile.d/profile.sh to /etc/profile.d

  - Symlink ${CLONE}/config to ~/.config

  - Symlink ${CLONE}/local to ~/.local

  - Start a new bash, enjoy!

Features:

  - Moving .dotfiles from the home directory into ~/.config and
    ~/.local as appropriate

  - Run clean_home to have your home directory checked for files that
    don't belong and should be merged / moved.

Settings:

  - Bash startup files in ~./config/sh/ with various goodies already
    configured

    - Colored prompt

    - Command output colorization

    - Bash completion

    - Less / LessPipe

    - Ls-aliases la, ll

    - Git

      - Don't autoconvert line endings

    - Gdb

      - Silent startup (no text blurb)

      - Text interface as default

      - Command window focus as default (command history)

    - Vim / NeoVim

      - plug.vim preinstalled to handle your plugins comfortably

      - Meaningful default configuration

        - <F2> toggles paste mode

        - <F3> toggles expandtab

        - Mouse control, scroll offset, incremental search, result highlighting,
          whitespace visibility, statusline warning about problematic encodings

      - Selection of plugins preconfigured

        - a.vim

          - :A to switch between .c/.cpp and .h files

          - :AS, :AV to split the screen

          - :IH to switch to file under cursor (e.g. includes)

          - :IHS, IHV to split the screen

        - taglist.vim

          - <F8> to open / close file overview sidebar

        - vim-dispatch

          - :Make does not block editor, quickfix window accessible while
            build is still running

        - vim-latex-suite

          - You might not require its awesome LaTeX editing features, but
            using <++> (or <+comment+>) as placeholders and jumping to them
            to insert things with <C-J> is nifty anywhere.

        - vim-startify

          - Start Vim empty and you get a nice most-recently-used list of files

        - vim-clang-format

          - Autoformat code according to .clang-format file (not yet properly
            configured)

        - coc.nvim

          - Language Server Protocol -- have Vim talk to Visual Studio for
            Autocompletion.

        - perforce_autoopen.vim

          - A little hack by myself to call "p4 open" on readonly files you are
            about to edit (should you have the misfortune to work with Perforce).

...and a lot more yet to come, or which I have forgotten to write about at this
point.
