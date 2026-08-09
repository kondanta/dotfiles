function topmem
    ps -e -orss=,args= | awk '{print $1 " " $2}' | awk '{tot[$2]+=$1;count[$2]++} END {for (i in tot) {print tot[i],i,count[i]}}' | sort -n | tail -n 15 | sort -nr | awk '{ hr=$1/1024; printf("%13.2fM", hr); print "\t" $2 }'
end
