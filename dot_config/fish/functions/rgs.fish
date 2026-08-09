function rgs
    set result (rg --ignore-case --color=always --line-number --no-heading --smart-case $argv | \
        fzf --ansi \
            --color 'hl:-1:underline,hl+:-1:underline:reverse' \
            --delimiter ':' \
            --preview "bat --color=always {1} --highlight-line {2}" \
            --preview-window 'up,65%,border-bottom,+{2}+3/3,~3')
    set file (echo $result | cut -d: -f1)
    set linenumber (echo $result | cut -d: -f2)
    if test -n "$file"
        switch "$EDITOR"
            case code
                $EDITOR --goto $file:$linenumber
            case '*'
                $EDITOR +$linenumber $file
        end
    end
end
