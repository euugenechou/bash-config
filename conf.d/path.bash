for _dir in "$HOME/.local/bin" "$HOME/go/bin" "$HOME/.cargo/bin" "$HOME/.docker/bin"; do
    [[ -d "$_dir" ]] && case ":$PATH:" in
        *":$_dir:"*) ;;
        *) PATH="$PATH:$_dir" ;;
    esac
done
unset _dir
