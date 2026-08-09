function grmm
    echo "Here's the branch list that is going to be deleted:"
    git branch --merged | grep -v '*'

    read -l -P "Do you wanna continue with the deletion operation?[y/n] " response

    switch $response
        case y Y yes YES
            git branch --merged | grep -v '*' | xargs -n 1 git branch -d
        case '*'
            echo "Cancelling..."
    end
end
