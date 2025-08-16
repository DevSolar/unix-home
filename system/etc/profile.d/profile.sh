# XDG Base Directory Specification
# https://specifications.freedesktop.org/basedir-spec/latest

test -n "$XDG_CONFIG_HOME" && XDG_CONFIG_HOME="${HOME}/.config"; export XDG_CONFIG_HOME
test -n "$XDG_CACHE_HOME"  && XDG_CACHE_HOME="${HOME}/.cache"; export XDG_CACHE_HOME
test -n "$XDG_DATA_HOME"   && XDG_DATA_HOME="${HOME}/.local/share"; export XDG_DATA_HOME
test -n "$XDG_STATE_HOME"  && XDG_STATE_HOME="${HOME}/.local/state"; export XDG_STATE_HOME
test -d "${HOME}/.local/bin" && PATH="${PATH}:${HOME}/.local/bin"; export PATH

# Shell Configurations in XDG_CONFIG_HOME

test -r "${XDG_CONFIG_HOME:-${HOME}/.config}/sh/profile" && . ${XDG_CONFIG_HOME:-${HOME}/.config}/sh/profile

case ${SHELL} in
    */bin/bash)
        test -r "${XDG_CONFIG_HOME:-${HOME}/.config}/sh/bash_profile" && . "${XDG_CONFIG_HOME:-${HOME}/.config}/sh/bash_profile"
        ;;
    */bin/ksh)
        test -r "${XDG_CONFIG_HOME:-${HOME}/.config}/sh/ksh_profile" && . "${XDG_CONFIG_HOME:-${HOME}/.config}/sh/ksh_profile"
        ;;
    *)
        ;;
esac
