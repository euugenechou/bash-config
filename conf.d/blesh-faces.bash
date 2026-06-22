# ble.sh syntax highlighting faces (only applied if ble.sh is loaded)
if [[ ${BLE_VERSION-} ]]; then
    ble-face -s command_file     fg=green,bold
    ble-face -s command_builtin  fg=green,bold
    ble-face -s command_alias    fg=green,bold
    ble-face -s command_function fg=green,bold
    ble-face -s command_keyword  fg=green,bold
fi
