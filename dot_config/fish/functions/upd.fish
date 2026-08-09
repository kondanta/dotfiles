function upd
    switch (uname)
        case Linux
            paru -Syyuv
        case Darwin
            brew update && brew upgrade
    end
end
