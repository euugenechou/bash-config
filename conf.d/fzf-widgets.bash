# fzf-powered widgets (requires fzf)
command -v fzf &>/dev/null || return

# Kill a process
fkill() {
    local pid
    pid=$(ps aux | sed 1d | fzf -m --header="Select process(es) to kill" | awk '{print $2}')
    [[ -n "$pid" ]] && echo "$pid" | xargs kill "${@:--15}"
}

# Pick a systemd unit and tail its journal
fjournal() {
    local unit
    unit=$(systemctl list-units --type=service --no-legend | fzf --header="Select unit to follow" | awk '{print $1}')
    [[ -n "$unit" ]] && journalctl -u "$unit" -f
}

# Pick a systemd service to restart
frestart() {
    local unit
    unit=$(systemctl list-units --type=service --no-legend | fzf --header="Select service to restart" | awk '{print $1}')
    [[ -n "$unit" ]] && sudo systemctl restart "$unit" && journalctl -u "$unit" -f
}

# Browse and tail log files
flog() {
    local logfile
    logfile=$(find /var/log -type f -readable 2>/dev/null | fzf --header="Select log to tail" --preview="tail -20 {}")
    [[ -n "$logfile" ]] && tail -f "$logfile"
}
