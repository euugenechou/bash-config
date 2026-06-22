# Optional tool integrations (guarded by availability)

# fzf
if command -v fzf &>/dev/null; then
    export FZF_DEFAULT_OPTS='--layout=reverse -m --bind ctrl-p:preview-up,ctrl-n:preview-down'

    # fzf 0.48+ has built-in shell integration
    if [[ "$(fzf --version 2>/dev/null | cut -d. -f1-2)" > "0.47" ]]; then
        eval "$(fzf --bash 2>/dev/null)"
    else
        for _fzf_dir in /usr/share/fzf /usr/share/doc/fzf/examples "$HOME/.fzf/shell"; do
            [[ -f "$_fzf_dir/key-bindings.bash" ]] && source "$_fzf_dir/key-bindings.bash"
            [[ -f "$_fzf_dir/completion.bash" ]] && source "$_fzf_dir/completion.bash"
        done
        unset _fzf_dir
    fi
fi

# direnv
command -v direnv &>/dev/null && eval "$(direnv hook bash)"

# cargo
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
