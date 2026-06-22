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

# -- source conf.d ------------------------------------------------------------

for _conf in "$DOTFILES_DIR"/conf.d/*.bash; do
    [[ -f "$_conf" ]] && source "$_conf"
done
unset _conf

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

    # Hide mode indicator (option is lazy-loaded with keymap.vi.sh)
    blehook keymap_load+='bleopt keymap_vi_mode_show='

    ble-attach
fi
