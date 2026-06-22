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

# -- optional dependency install ----------------------------------------------

# canonical-name  command-to-check  apt-name   dnf-name   pacman-name  brew-name
DEPS=(
    "eza       eza       eza       eza       eza       eza"
    "fzf       fzf       fzf       fzf       fzf       fzf"
    "fd        fd        fd-find   fd-find   fd        fd"
    "ripgrep   rg        ripgrep   ripgrep   ripgrep   ripgrep"
    "bat       bat       bat       bat       bat       bat"
    "direnv    direnv    direnv    direnv    direnv    direnv"
    "git       git       git       git       git       git"
)

detect_pkg_manager() {
    if command -v apt-get &>/dev/null; then echo "apt"
    elif command -v dnf &>/dev/null; then echo "dnf"
    elif command -v pacman &>/dev/null; then echo "pacman"
    elif command -v brew &>/dev/null; then echo "brew"
    else echo "unknown"
    fi
}

install_deps() {
    local pm
    pm="$(detect_pkg_manager)"

    if [[ "$pm" == "unknown" ]]; then
        error "No supported package manager found (apt/dnf/pacman/brew)."
        return 1
    fi

    if [[ "$pm" != "brew" ]] && ! command -v sudo &>/dev/null; then
        error "sudo not available — cannot install packages."
        return 1
    fi

    # Map package manager to column index in DEPS table
    local col
    case "$pm" in
        apt)    col=2 ;;
        dnf)    col=3 ;;
        pacman) col=4 ;;
        brew)   col=5 ;;
    esac

    local -a missing=()
    local -a already=()
    for entry in "${DEPS[@]}"; do
        read -ra fields <<< "$entry"
        local name="${fields[0]}" cmd="${fields[1]}" pkg="${fields[$col]}"
        if command -v "$cmd" &>/dev/null; then
            already+=("$name")
        else
            missing+=("$pkg")
        fi
    done

    if [[ ${#already[@]} -gt 0 ]]; then
        info "Already installed: ${already[*]}"
    fi

    if [[ ${#missing[@]} -eq 0 ]]; then
        info "All dependencies already installed."
        return 0
    fi

    echo ""
    info "Package manager: $pm"
    info "Will install: ${missing[*]}"
    echo ""
    read -rp "Proceed? [y/N] " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || { info "Skipped."; return 0; }

    case "$pm" in
        apt)    sudo apt-get update && sudo apt-get install -y "${missing[@]}" ;;
        dnf)    sudo dnf install -y "${missing[@]}" ;;
        pacman) sudo pacman -S --noconfirm "${missing[@]}" ;;
        brew)   brew install "${missing[@]}" ;;
    esac

    info "Dependencies installed."
}

# -- main ---------------------------------------------------------------------

main() {
    local do_deps=false

    for arg in "$@"; do
        case "$arg" in
            --install-deps) do_deps=true ;;
            -h|--help)
                echo "Usage: install.sh [--install-deps]"
                echo ""
                echo "  --install-deps  Install eza, fzf, fd, ripgrep, bat, direnv, git"
                exit 0
                ;;
            *)
                error "Unknown argument: $arg"
                exit 1
                ;;
        esac
    done

    build_blesh
    setup_symlinks

    if [[ "$do_deps" == true ]]; then
        install_deps
    fi

    echo ""
    info "Done! Restart your shell or run: source ~/.bashrc"
}

main "$@"
