function fish_greeting
    if not command -q kitten; or not command -q fastfetch
        return
    end

    set -l img ~/.config/fish/image/katana.png
    if not test -f $img
        fastfetch --logo none
        return
    end

    set -l img_cols 28
    set -l img_rows 15
    set -l img_top 4    # lines above image: break, VITALS, CPU, GPU
    set -l gap 3
    set -l img_px_w 800
    set -l img_px_h 950
    set -l text_col (math $img_cols + $gap + 1)

    set -l ff_lines (fastfetch --logo none 2>/dev/null)
    set -l ff_count (count $ff_lines)
    set -l img_bottom (math $img_top + $img_rows)
    set -l total_rows (math "max($img_bottom, $ff_count)")

    printf "\n%.0s" (seq $total_rows)
    printf "\033[%dA" $total_rows

    set -l cur_row (python3 -c "
import termios, tty, re
try:
    fd = open('/dev/tty', 'rb+', buffering=0)
    old = termios.tcgetattr(fd)
    tty.setraw(fd)
    fd.write(b'\033[6n')
    resp = b''
    while True:
        c = fd.read(1)
        resp += c
        if c == b'R': break
    termios.tcsetattr(fd, termios.TCSADRAIN, old)
    m = re.search(rb'\[(\d+);', resp)
    if m: print(int(m.group(1).decode()) - 1)
except: pass
" 2>/dev/null)

    if test -z "$cur_row"
        fastfetch --logo none
        return
    end

    set -l img_tmp /tmp/fish_greeting_img.png
    magick $img -resize {$img_px_w}x{$img_px_h}! $img_tmp 2>/dev/null

    set -l img_row (math $cur_row + $img_top)
    kitten icat --align left \
        --place {$img_cols}x{$img_rows}@0x{$img_row} $img_tmp 2>/dev/null

    printf "\033[%dA" $img_top

    for i in (seq $ff_count)
        printf "\033[%dG" $text_col
        printf "%s\n" $ff_lines[$i]
    end

    if test $ff_count -lt $total_rows
        printf "\033[%dB" (math $total_rows - $ff_count)
    end
    printf "\033[1G"
end
