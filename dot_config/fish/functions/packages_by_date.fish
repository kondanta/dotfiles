function packages_by_date
    pacman -Qi | grep -E '^\(Name\|Install Date\)\s*:' | cut -d ':' -f 2- | paste - - | while read -l line
        set pkg_name (echo $line | awk '{print $NF}')
        set install_date (echo $line | awk '{$NF=""; print $0}' | string trim)
        set install_date (date --date="$install_date" -Iseconds 2>/dev/null)
        echo "$install_date $pkg_name"
    end | sort
end
