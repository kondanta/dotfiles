function newline_to_comma
    if test (count $argv) -ne 2
        echo "Usage: newline_to_comma <inputFile> <outputFile>"
        return 1
    end
    cat $argv[1] | sed -n -e 'H;${x;s/\n/,/g;s/^,//;p;}' > $argv[2]
end
