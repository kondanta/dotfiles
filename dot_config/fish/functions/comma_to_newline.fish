function comma_to_newline
    if test (count $argv) -ne 2
        echo "Usage: comma_to_newline 'Some,text,with,commas' <outputFile>"
        return 1
    end
    echo $argv[1] | tr ',' '\n' > $argv[2]
end
