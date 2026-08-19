set -gx EDITOR nvim
set -gx VISUAL nvim

if status is-interactive && not set -q TMUX
    ~/.config/tmux/caelestia-colors.sh 2>/dev/null
    cat ~/.local/state/caelestia/sequences.txt 2>/dev/null
    exec tmux new-session -A -s main
end

if status is-interactive
    command -v starship &> /dev/null && starship init fish | source
    command -v direnv &> /dev/null && direnv hook fish | source
    command -v zoxide &> /dev/null && zoxide init fish | source
    command -q fzf && fzf --fish | source

    cat ~/.local/state/caelestia/sequences.txt 2> /dev/null

    set -q XDG_CONFIG_HOME && set -l cConf $XDG_CONFIG_HOME/caelestia || set -l cConf $HOME/.config/caelestia
    source $cConf/user-config.fish 2> /dev/null
end

atuin init fish | source
