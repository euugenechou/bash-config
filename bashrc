# ~/.bashrc — portable bash config
# Symlinked from ~/dotfiles-bash/bashrc

# Exit early if not interactive
[[ $- != *i* ]] && return

# -- system defaults ----------------------------------------------------------

[[ -f /etc/bashrc ]] && source /etc/bashrc

# -- ble.sh early init (deferred attach for speed) ---------------------------

DOTFILES_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo "${BASH_SOURCE[0]}")")" && pwd)"
_blesh="${DOTFILES_DIR}/blesh/out/ble.sh"
if [[ -f "$_blesh" ]]; then
    source "$_blesh" --attach=none
fi
unset _blesh

# -- source conf.d ------------------------------------------------------------

for _conf in "$DOTFILES_DIR"/conf.d/*.bash; do
    [[ -f "$_conf" ]] && source "$_conf"
done
unset _conf

# -- ble.sh attach (must be last) --------------------------------------------

if [[ ${BLE_VERSION-} ]]; then
    bleopt input_encoding=UTF-8

    # Vi-mode as default keymap
    bleopt default_keymap=vi

    # Hide mode indicator (option is lazy-loaded with keymap.vi.sh)
    blehook keymap_load+='bleopt keymap_vi_mode_show='

    ble-attach
fi
