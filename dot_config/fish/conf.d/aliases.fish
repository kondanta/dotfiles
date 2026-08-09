# System
abbr p 'sudo pacman'
abbr g 'git'
abbr sdn 'sudo shutdown -h now'
abbr nf 'clear && neofetch'
abbr md 'mkdir -p'
abbr cal 'cal -w'
abbr lsp 'pacman -Qett --color=always | less'

alias du='dust'
alias grep='grep --color=auto'
alias mv='mv -v'
alias cp='cp -v'
alias vim='nvim'
alias e='emacsclient -c -a emacs'
alias ffmpeg='ffmpeg -hide_banner'

# Clipboard (Wayland)
alias pst='wl-paste'
alias cpy='wl-copy'

# ls
alias ls='eza --color=always --icons --group-directories-first'
alias la='eza --color=always --long --icons=always --no-time --no-filesize --git -a'
alias ll='eza --color=always --long --icons=always --git --time-style long-iso'
abbr l 'ls'
abbr lla 'la'

# Archives
abbr mktar 'tar -cvf'
abbr mkbz2 'tar -cvjf'
abbr mkgz 'tar -cvzf'
abbr untar 'tar -xvf'
abbr unbz2 'tar -xvjf'
abbr ungz 'tar -xvzf'

# Tmux
abbr t 'tmux -2'
abbr tn 'tmux -2 new -s'
abbr ta 'tmux -2 a -t'
abbr tls 'tmux -2 ls'
abbr tk 'tmux -2 kill-window -t'
