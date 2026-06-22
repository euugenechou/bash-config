#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

info()  { printf '\033[1;34m::\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m::\033[0m %s\n' "$*"; }
error() { printf '\033[1;31m::\033[0m %s\n' "$*" >&2; }

# -- ble.sh submodule ---------------------------------------------------------

build_blesh() {
    info "Initializing ble.sh submodule..."
    cd "$DOTFILES_DIR"
    git submodule update --init --recursive

    if [[ -f "$DOTFILES_DIR/blesh/out/ble.sh" ]]; then
        info "ble.sh already built — skipping."
        return
    fi

    if ! command -v make &>/dev/null; then
        warn "make not found — skipping ble.sh build."
        warn "Install make and re-run, or bashrc will fall back to plain readline."
        return
    fi

    info "Building ble.sh..."
    if ! make -C blesh; then
        warn "ble.sh build failed (missing gawk?). bashrc will fall back to plain readline."
    fi
}

# -- symlinks -----------------------------------------------------------------

link_file() {
    local src="$1" dst="$2" name="$3"

    # Already correct
    if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
        info "$name already linked."
        return
    fi

    # Backup existing file
    if [[ -e "$dst" || -L "$dst" ]]; then
        local backup="${dst}.bak.${TIMESTAMP}"
        warn "Backing up existing $name to $backup"
        mv "$dst" "$backup"
    fi

    ln -s "$src" "$dst"
    info "Linked $name -> $src"
}

setup_symlinks() {
    link_file "$DOTFILES_DIR/bashrc" "$HOME/.bashrc" ".bashrc"
    link_file "$DOTFILES_DIR/inputrc" "$HOME/.inputrc" ".inputrc"
}

# -- dependency check ---------------------------------------------------------

# name:command pairs — all optional, bashrc degrades gracefully without them
DEPS=(
    "eza:eza"
    "fzf:fzf"
    "fd:fd"
    "ripgrep:rg"
    "bat:bat"
    "direnv:direnv"
)

check_deps() {
    local -a missing=()
    for entry in "${DEPS[@]}"; do
        local name="${entry%%:*}" cmd="${entry#*:}"
        command -v "$cmd" &>/dev/null || missing+=("$name")
    done

    if [[ ${#missing[@]} -eq 0 ]]; then
        info "All optional dependencies found."
    else
        warn "Missing optional dependencies: ${missing[*]}"
    fi
}

# -- main ---------------------------------------------------------------------

usage() {
    echo "Usage: install.sh [-h]"
    echo ""
    echo "Sets up ble.sh, symlinks bashrc/inputrc, and checks for optional deps."
}

main() {
    local opts
    opts=$(getopt -o h -l help -n install.sh -- "$@") || { usage >&2; exit 1; }
    eval set -- "$opts"

    while true; do
        case "$1" in
            -h|--help) usage; exit 0 ;;
            --) shift; break ;;
        esac
    done

    build_blesh
    setup_symlinks
    check_deps

    echo ""
    info "Done! Restart your shell or run: source ~/.bashrc"
}

main "$@"
