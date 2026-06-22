# ~/.bashrc — portable bash config
# Symlinked from ~/dotfiles-bash/bashrc

# Exit early if not interactive
[[ $- != *i* ]] && return

# -- ble.sh early init (deferred attach for speed) ---------------------------

DOTFILES_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo "${BASH_SOURCE[0]}")")" && pwd)"
_blesh="${DOTFILES_DIR}/blesh/out/ble.sh"
if [[ -f "$_blesh" ]]; then
    source "$_blesh" --attach=none
fi
unset _blesh

# -- shell options ------------------------------------------------------------

shopt -s histappend
shopt -s checkwinsize
shopt -s globstar 2>/dev/null

HISTCONTROL=ignoreboth:erasedups
HISTSIZE=10000
HISTFILESIZE=20000

# -- PATH ---------------------------------------------------------------------

for _dir in "$HOME/.local/bin" "$HOME/go/bin" "$HOME/.cargo/bin" "$HOME/.docker/bin"; do
    [[ -d "$_dir" ]] && case ":$PATH:" in
        *":$_dir:"*) ;;
        *) PATH="$PATH:$_dir" ;;
    esac
done
unset _dir

# -- aliases ------------------------------------------------------------------

alias b='cd "$OLDPWD"'
alias c='clear'
alias bashsrc='source ~/.bashrc'

if command -v eza &>/dev/null; then
    alias ls='eza'
    alias ll='eza -l --group'
    alias la='eza -a --group'
    alias l='eza -la --group'
else
    alias ls='ls --color=auto'
    alias ll='ls -l'
    alias la='ls -a'
    alias l='ls -la'
fi

# -- prompt -------------------------------------------------------------------

__git_branch() {
    local branch
    branch="$(git symbolic-ref --short HEAD 2>/dev/null)" ||
        branch="$(git rev-parse --short HEAD 2>/dev/null)" ||
        return
    printf ' %s' "$branch"
}

__set_prompt() {
    PS1='\[\e[1;31m\]\u\[\e[0m\] \[\e[1;33m\]\w\[\e[0m\]\[\e[1;35m\]$(__git_branch)\[\e[0m\]\n\$ '
}

PROMPT_COMMAND='__set_prompt'

# -- fzf ----------------------------------------------------------------------

if command -v fzf &>/dev/null; then
    export FZF_DEFAULT_OPTS='--layout=reverse -m --bind ctrl-p:preview-up,ctrl-n:preview-down'

    # fzf 0.48+ has built-in shell integration
    if [[ "$(fzf --version 2>/dev/null | cut -d. -f1-2)" > "0.47" ]]; then
        eval "$(fzf --bash 2>/dev/null)"
    else
        # Fall back to sourcing scripts from common install locations
        for _fzf_dir in /usr/share/fzf /usr/share/doc/fzf/examples "$HOME/.fzf/shell"; do
            [[ -f "$_fzf_dir/key-bindings.bash" ]] && source "$_fzf_dir/key-bindings.bash"
            [[ -f "$_fzf_dir/completion.bash" ]] && source "$_fzf_dir/completion.bash"
        done
        unset _fzf_dir
    fi
fi

# -- direnv -------------------------------------------------------------------

if command -v direnv &>/dev/null; then
    eval "$(direnv hook bash)"
fi

# -- cargo --------------------------------------------------------------------

[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# -- ble.sh attach (must be last) --------------------------------------------

if [[ ${BLE_VERSION-} ]]; then
    bleopt input_encoding=UTF-8

    # Vi-mode as default keymap
    bleopt default_keymap=vi

    ble-attach
fi
