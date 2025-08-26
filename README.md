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

Recommendations not part of this repo:

  - Vim users: Install Microsoft PowerToys, and use the keyboard
    manager to remap Caps-Lock to Escape. This makes a *huge*
    difference as you don't need to take your left hand off the
    home row all the time.
    If you are straddled with a Dell laptop like me, which tells
    you about every press of the Caps-Lock key with a rather
    intrusive screen overlay notification, start the Dell Display
    and Peripheral Manager from the Start Menu, click on the gears
    icon in the titlebar, and in the "General" tab, disable the
    Caps-Lock notification.

  - German users: Install the US International Alternate keymap,
    http://keyboards.jargon-file.org/altinter.zip, and get a US
    QWERTY keyboard. (NOT a UK QWERTY layout, NOT a "US International"
    layout. A genuine US keyboard, one where the <Enter> key is not
    two rows tall, with the []{}\| keys above it.) Apart from that,
    this layout gives you ;: on one key, '" on another, and <> next
    to each other, intuitively grouped and without combining AltGr
    with right-hand keys toward the center of the keyboard (awkward
    wrist-twister!).
    The Umlauts are on AltGr-q, AltGr-y and AltGr-p, plus the EsZett
    on AltGr-s. AltGr with backtick, caret or '" gives you "dead key"
    behavior for funnyness like ë or î, and çæåð©ñ etc. are also
    easily available.
    You get used to the new layout quickly, and again it makes a
    *huge* difference, especially when typing code. It also makes
    the Vim shortcut ZZ for save & exit easy.

Dependencies:

  - Vim plugin CoC requires nodejs, npm, clangd. Using CoC with MSVC
    requires the Clang Power Tools plugin to MSVC (and exporting the
    compilation database for the solution -- right-click in the
    solution explorer on the solution, Clang Power Tools, Export
    Compilation Database -- this takes a while to complete).

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

        - Run :PlugInstall to install the plugins configured in vimrc.plugins!

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

        - NERDTree

          - Press <C-n> to get a file browser sidebar, where you can bookmark
            project directories.

        - Vim Fugitive

          - Instead of leaving Vim for Git commands, just go :Git <command>.

          - Git Blame and other features integrated into Vim

...and a lot more yet to come, or which I have forgotten to write about at this
point.
