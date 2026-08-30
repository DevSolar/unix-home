# XDG Base Directory Specification
# https://specifications.freedesktop.org/basedir-spec/latest

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}"
test -d "${HOME}/.local/bin" && PATH="${HOME}/.local/bin:${PATH}"; export PATH

# Shell Configurations in XDG_CONFIG_HOME

test -r "${XDG_CONFIG_HOME}/sh/profile" && . "${XDG_CONFIG_HOME}/sh/profile"

case ${SHELL} in
    */bin/bash)
        test -r "${XDG_CONFIG_HOME}/sh/bash_profile" && . "${XDG_CONFIG_HOME}/sh/bash_profile"
        ;;
    */bin/ksh)
        test -r "${XDG_CONFIG_HOME}/sh/ksh_profile" && . "${XDG_CONFIG_HOME}/sh/ksh_profile"
        ;;
    *)
        ;;
esac
