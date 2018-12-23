#!/bin/bash
# author: Aysad Kozanoglu
#
# usage :
# script.sh  http://domain.com,https://test.com,http://test2.com:4000


   urls=$@
   WGET=$(which wget)
results=$(mktemp)"_resulturls"

# Split URLs by comma
   urls=${urls//,/ }

echo $urls >> /tmp/vars

for url in $urls
   do
      if [ "$(echo $url | cut -d: -f 1)" == "https" ]; then
        conntype="https"
      else
        conntype="http"
      fi
  	   # -t try connection x times
	   # -- timeout max execution 
	   # --connect-timeout  max request execution time
	    $WGET -t 2 --timeout=30 --connect-timeout=20 -q -O $(mktemp)"_checkUrl" $url && echo $url ok >> $results || echo $url NOK >> $results
done

if cat $results | grep "NOK" > /dev/null; then
       echo "Website  Failed:"
       cat $results | grep "NOK"
       EXITCODE=2
else
       echo -e "All URLs OK:"
       cat $results
       EXITCODE=0
fi

exit   $EXITCODE
