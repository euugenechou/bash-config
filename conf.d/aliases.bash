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
