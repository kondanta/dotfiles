function pkgInfo
    pacman -Qq | fzf --preview 'pacman -Qil {} | bat -fpl yml' --layout=reverse --bind 'enter:execute(pacman -Qil {} | less)'
end
