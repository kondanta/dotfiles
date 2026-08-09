function gsignall
    git filter-branch --commit-filter 'git commit-tree -S "$@";' -- --all
end
