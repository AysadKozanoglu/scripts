#!/bin/bash

# Author: Aysad Kozanoglu 

meminfo="/usr/bin/free"

xmlresult=`cat <<EOF
<?xml version="1.0" encoding='UTF-8'?>
<prtg>
EOF
`

if [ -f $meminfo ]; then
  result=`free -b | grep 'Mem\|Swap'`
  while read line; do
    if [[ $line == Mem* ]]; then
      total=`echo $line | awk '{print $2}'`
      used=`echo $line | awk '{print $3}'`
      free=`echo $line | awk '{print $4}'`
      shared=`echo $line | awk '{print $5}'`
      buffers=`echo $line | awk '{print $6}'`
      cache=`echo $line | awk '{print $7}'`
    else
      swtotal=`echo $line | awk '{print $2}'`
      swused=`echo $line | awk '{print $3}'`
      swfree=`echo $line | awk '{print $4}'`
    fi
  done <<< "$result"

  physicalusedperc=`echo $used $buffers $cache $total | \
    awk '{printf("%.3f", ($1-$2-$3)*100/$4)}'`
  xmlresult+=`cat <<EOF

  <result>
    <channel>Physical Used Percent</channel>
    <float>1</float>
    <unit>Percent</unit>
    <value>$physicalusedperc</value>
  </result>
EOF
`
  physicalfreebytes=`echo $used $buffers $cache $total | \
    awk '{printf("%i", $4-($1-$2-$3))}'`
  xmlresult+=`cat <<EOF

  <result>
    <channel>Physical Free</channel>
    <float>0</float>
    <unit>BytesMemory</unit>
    <value>$physicalfreebytes</value>
  </result>
EOF
`


  swapusedperc=`echo $swtotal $swused | \
    awk '{printf("%.3f", ($2/$1)*100)}'`
  xmlresult+=`cat <<EOF

  <result>
    <channel>Swap Used Percent</channel>
    <float>1</float>
    <unit>Percent</unit>
    <value>$swapusedperc</value>
  </result>
EOF
`
  xmlresult+=`cat <<EOF

  <result>
    <channel>Swap Used</channel>
    <float>0</float>
    <unit>BytesMemory</unit>
    <value>$swused</value>
  </result>
EOF
`
  xmlresult+=`cat <<EOF

  <result>
    <channel>Swap Free</channel>
    <float>0</float>
    <unit>BytesMemory</unit>
    <value>$swfree</value>
  </result>
EOF
`
  totalusedperc=`echo $used $buffers $cache $total $swused $swtotal | \
    awk '{printf("%.3f", ($1-$2-$3+$5)*100/($4+$6))}'`
  xmlresult+=`cat <<EOF

  <result>
    <channel>Total Used Percent</channel>
    <float>1</float>
    <unit>Percent</unit>
    <value>$totalusedperc</value>
  </result>
EOF
`
  totalfreebytes=`echo $used $buffers $cache $total $swused $swtotal | \
    awk '{printf("%i", ($4+$6)-($1-$2-$3+$5))}'`
  xmlresult+=`cat <<EOF

  <result>
    <channel>Total Free</channel>
    <float>0</float>
    <unit>BytesMemory</unit>
    <value>$totalfreebytes</value>
  </result>
EOF
`


  xmlresult+=`cat <<EOF

  <text>OK</text>
</prtg>
EOF
`

else
  xmlresult+=`cat <<EOF

  <error>1</error>
  <text>This sensor is not supported by your system, missing $proc</text>
</prtg>
EOF
`
fi

echo "$xmlresult"

exit 0
