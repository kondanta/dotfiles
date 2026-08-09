function gbd
    if test -n "$argv[1]"
        git branch -D $argv
    else
        git branch | fzf | string trim | xargs git branch -D
    end
end
