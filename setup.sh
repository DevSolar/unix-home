#!/usr/bin/env bash
#
# setup.sh - Automated setup script for unix-home dotfiles environment
#
# Merges pre-existing ~/.config and ~/.local into this repository,
# creates the required symlinks, installs system environment hooks,
# and backs up any conflicting configuration files.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_CONFIG="$SCRIPT_DIR/config"
REPO_LOCAL="$SCRIPT_DIR/local"
REPO_SYSTEM_PROFILE="$SCRIPT_DIR/system/etc/profile.d/clean_home.sh"

DRY_RUN=false
VERBOSE=false
BACKUP_DIR=""

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Automated setup for the unix-home environment.

Options:
  -n, --dry-run     Show what would be done without making changes
  -v, --verbose     Print detailed actions
  -b, --backup DIR  Specify custom backup directory (default: ~/.unix-home-backup-TIMESTAMP)
  -h, --help        Display this help message
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -b|--backup)
            BACKUP_DIR="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Error: Unknown option $1" >&2
            usage
            exit 1
            ;;
    esac
done

if [[ -z "$BACKUP_DIR" ]]; then
    TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
    BACKUP_DIR="$HOME/.unix-home-backup-$TIMESTAMP"
fi

log() {
    echo "[setup] $*"
}

log_verbose() {
    if [[ "$VERBOSE" == true ]]; then
        echo "[setup:verbose] $*"
    fi
}

run_cmd() {
    if [[ "$DRY_RUN" == true ]]; then
        echo "[dry-run] $*"
    else
        "$@"
    fi
}

# Recursively merge src_dir into dst_dir
merge_dir() {
    local src_dir="$1"
    local dst_dir="$2"
    local cur_bak_dir="$3"

    shopt -s dotglob nullglob
    local items=("$src_dir"/*)
    shopt -u dotglob nullglob

    for src_item in "${items[@]}"; do
        local base_name="$(basename "$src_item")"
        if [[ "$base_name" == "." || "$base_name" == ".." ]]; then
            continue
        fi

        local dst_item="$dst_dir/$base_name"
        local bak_item="$cur_bak_dir/$base_name"

        if [[ ! -e "$dst_item" && ! -L "$dst_item" ]]; then
            log "Merging new item '$base_name' into '$(basename "$dst_dir")'"
            if [[ "$DRY_RUN" == true ]]; then
                echo "[dry-run] mv '$src_item' '$dst_item'"
            else
                mv "$src_item" "$dst_item"
            fi
        elif [[ -d "$src_item" && ! -L "$src_item" && -d "$dst_item" && ! -L "$dst_item" ]]; then
            log_verbose "Recursing into directory '$base_name'"
            merge_dir "$src_item" "$dst_item" "$bak_item"
        else
            log "Conflict detected for '$base_name': backing up existing file to '$bak_item'"
            if [[ "$DRY_RUN" == true ]]; then
                echo "[dry-run] mkdir -p '$cur_bak_dir' && mv '$src_item' '$bak_item'"
            else
                mkdir -p "$cur_bak_dir"
                mv "$src_item" "$bak_item"
            fi
        fi
    done
}

setup_target() {
    local target_path="$1"
    local repo_path="$2"
    local dir_name="$(basename "$target_path")"

    log "Processing $target_path..."

    if [[ -L "$target_path" ]]; then
        local link_target
        link_target="$(readlink -f "$target_path" 2>/dev/null || echo "")"
        local expected_target
        expected_target="$(readlink -f "$repo_path" 2>/dev/null || echo "")"

        if [[ -n "$link_target" && "$link_target" == "$expected_target" ]]; then
            log "$target_path is already symlinked to $repo_path."
            return 0
        else
            log "$target_path is a symlink to '$link_target'. Replacing with symlink to $repo_path."
            run_cmd rm "$target_path"
            run_cmd ln -s "$repo_path" "$target_path"
            return 0
        fi
    fi

    if [[ -d "$target_path" ]]; then
        log "$target_path exists as a directory. Merging contents with $repo_path..."
        local bak_sub_dir="$BACKUP_DIR/$dir_name"
        merge_dir "$target_path" "$repo_path" "$bak_sub_dir"

        log "Removing old directory $target_path..."
        run_cmd rm -rf "$target_path"
    elif [[ -e "$target_path" ]]; then
        log "$target_path exists and is not a directory. Backing up to $BACKUP_DIR/$dir_name..."
        if [[ "$DRY_RUN" == true ]]; then
            echo "[dry-run] mkdir -p '$BACKUP_DIR' && mv '$target_path' '$BACKUP_DIR/$dir_name'"
        else
            mkdir -p "$BACKUP_DIR"
            mv "$target_path" "$BACKUP_DIR/$dir_name"
        fi
    fi

    log "Creating symlink $target_path -> $repo_path"
    run_cmd ln -s "$repo_path" "$target_path"
}

setup_system_profile() {
    local sys_target="/etc/profile.d/clean_home.sh"
    log "Checking system profile initialization file $sys_target..."

    if [[ -f "$sys_target" || -L "$sys_target" ]]; then
        local current_real
        current_real="$(readlink -f "$sys_target" 2>/dev/null || echo "")"
        local expected_real
        expected_real="$(readlink -f "$REPO_SYSTEM_PROFILE" 2>/dev/null || echo "")"
        if [[ -n "$current_real" && "$current_real" == "$expected_real" ]]; then
            log "$sys_target is already set up."
            return 0
        fi
    fi

    log "Installing $sys_target..."
    if [[ "$DRY_RUN" == true ]]; then
        echo "[dry-run] sudo cp '$REPO_SYSTEM_PROFILE' '$sys_target'"
        return 0
    fi

    if [[ -w "/etc/profile.d" ]]; then
        cp "$REPO_SYSTEM_PROFILE" "$sys_target"
        chmod 644 "$sys_target"
        log "Successfully copied $sys_target"
    elif [[ -t 0 ]] && command -v sudo >/dev/null 2>&1; then
        log "Requesting sudo privileges to install $sys_target..."
        if sudo cp "$REPO_SYSTEM_PROFILE" "$sys_target" && sudo chmod 644 "$sys_target"; then
            log "Successfully installed $sys_target"
        else
            log "Warning: Failed to copy $sys_target using sudo."
            log "Please run manually: sudo cp '$REPO_SYSTEM_PROFILE' '$sys_target'"
        fi
    else
        log "Notice: Installing to /etc/profile.d requires root/sudo access."
        log "Please run manually: sudo cp '$REPO_SYSTEM_PROFILE' '$sys_target'"
    fi
}

setup_system_bashrc() {
    local bashrc_target="/etc/bash.bashrc"
    local source_line='test -r "${XDG_CONFIG_HOME:-$HOME/.config}/sh/bash_aliases" && . "${XDG_CONFIG_HOME:-$HOME/.config}/sh/bash_aliases"'

    log "Checking system bashrc initialization in $bashrc_target..."

    if [[ ! -f "$bashrc_target" ]]; then
        log "Notice: $bashrc_target does not exist. Skipping."
        return 0
    fi

    if grep -Fq "$source_line" "$bashrc_target" 2>/dev/null; then
        log "$bashrc_target is already configured."
        return 0
    fi

    log "Adding bash_aliases sourcing to $bashrc_target..."
    if [[ "$DRY_RUN" == true ]]; then
        echo "[dry-run] Add '$source_line' to $bashrc_target"
        return 0
    fi

    local tmp_file
    tmp_file="$(mktemp)"
    python3 -c '
import sys

target, line_to_add, out_file = sys.argv[1], sys.argv[2], sys.argv[3]
with open(target, "r") as f:
    lines = f.readlines()

trailing_empty = []
while lines and lines[-1].strip() == "":
    trailing_empty.append(lines.pop())

if lines and lines[-1].strip().startswith("#"):
    last_comment = lines.pop()
    lines.append(line_to_add + "\n")
    lines.append(last_comment)
else:
    lines.append(line_to_add + "\n")

lines.extend(trailing_empty)

with open(out_file, "w") as f:
    f.writelines(lines)
' "$bashrc_target" "$source_line" "$tmp_file"

    if [[ -w "$bashrc_target" ]]; then
        cp "$tmp_file" "$bashrc_target"
        rm -f "$tmp_file"
        log "Successfully updated $bashrc_target"
    elif [[ -t 0 ]] && command -v sudo >/dev/null 2>&1; then
        log "Requesting sudo privileges to update $bashrc_target..."
        if sudo cp "$tmp_file" "$bashrc_target"; then
            rm -f "$tmp_file"
            log "Successfully updated $bashrc_target"
        else
            rm -f "$tmp_file"
            log "Warning: Failed to update $bashrc_target using sudo."
            log "Please run manually: sudo tee -a '$bashrc_target' <<< '$source_line'"
        fi
    else
        rm -f "$tmp_file"
        log "Notice: Updating $bashrc_target requires root/sudo access."
        log "Please run manually: sudo tee -a '$bashrc_target' <<< '$source_line'"
    fi
}

main() {
    log "Starting unix-home setup..."
    log "Repository root: $SCRIPT_DIR"

    setup_target "$HOME/.config" "$REPO_CONFIG"
    setup_target "$HOME/.local" "$REPO_LOCAL"

    setup_system_profile
    setup_system_bashrc

    if [[ -d "$BACKUP_DIR" ]]; then
        log "Backed up pre-existing conflicting files to: $BACKUP_DIR"
    fi

    log "Setup complete! Restart your shell or run 'source /etc/profile.d/clean_home.sh'."
}

main "$@"
