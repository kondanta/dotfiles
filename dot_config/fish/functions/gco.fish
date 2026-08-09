function gco
    if test -n "$argv[1]"
        git checkout $argv
    else
        git branch | fzf | string trim | xargs git checkout
    end
end
