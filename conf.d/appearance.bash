# Prompt
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

# ble.sh syntax highlighting
if [[ ${BLE_VERSION-} ]]; then
    ble-face -s command_file     fg=green,bold
    ble-face -s command_builtin  fg=green,bold
    ble-face -s command_alias    fg=green,bold
    ble-face -s command_function fg=green,bold
    ble-face -s command_keyword  fg=green,bold
    ble-face -s syntax_error     fg=red,bold
fi
