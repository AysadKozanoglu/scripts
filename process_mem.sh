#!/bin/bash
# email:aysadx@gmail.com
#
# usage example:
# to get ram usage of nginx process
# proc_mem.sh nginx

if ps auxf | grep  $1 | grep -v grep > /dev/null ; 
   then 
    ps -C $1 -O rss | awk '{ count ++; sum += $2 }; END {count --; print "Number of processes =",count; print "Memory usage per process =",sum/1024/count, "MB"; print "Total memory usage =", sum/1024, "MB" ;};'
  else
    echo "process $1 not found"
fi
