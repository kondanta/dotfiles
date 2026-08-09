function rankpacman
    curl -s "https://archlinux.org/mirrorlist/?country=NO&country=SE&protocol=https&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 5 -
end
