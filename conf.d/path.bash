_extra_paths=(
    "$HOME/.local/bin"
    "$HOME/go/bin"
    "$HOME/.cargo/bin"
    "$HOME/.docker/bin"
)

for _dir in "${_extra_paths[@]}"; do
    [[ -d "$_dir" ]] && case ":$PATH:" in
        *":$_dir:"*) ;;
        *) PATH="$PATH:$_dir" ;;
    esac
done
unset _dir _extra_paths
