function tm
    set folder (zoxide query $argv[1])
    set session_name (basename $folder | tr ' .:' '_')

    if not tmux has-session -t $session_name 2>/dev/null
        tmux new-session -d -s $session_name -c $folder
    end

    if test -z "$TMUX"
        tmux attach -t $session_name
    else
        tmux switch-client -t $session_name
    end
end
