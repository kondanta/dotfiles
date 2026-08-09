function ga
    git ls-files -m -o --exclude-standard \
    | fzf -m --ansi --print0 --preview "git diff --color=always -- {1}" \
    | xargs -0 git add
end
