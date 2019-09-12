#!/bin/bash

# Author: Aysad Kozanoglu
# Backup all Citrix XEN VMS to NFS Shared Storage

       DATE=`date +%d%b%Y`
     XSNAME=`echo $HOSTNAME`
   UUIDFILE=/tmp/xen-uuids.txt
      NFSIP=192.168.1.100
  NFSSHARE=/data/VMS
   NFSPOINT=${NFSIP}:${NFSSHARE}
 MOUNTPOINT=/mnt/backupVMS
 BACKUPPATH=${MOUNTPOINT}/${XSNAME}/${DATE}
 LOGFILEVMS=/var/log/backupvms.log


mkdir -p ${BACKUPPATH}

if [ ! -d ${MOUNTPOINT} ]
 then 
	echo "No mount point found, kindly check"; 
  mount $NFSPOINT $MOUNTPOINT
	# exit 0;
fi

echo "mount check ok"

if [ ! -d ${BACKUPPATH} ]
 then 
	echo "No backup directory found"; 
	exit 0;
fi 

echo "backuppath ok"

# Fetching list UUIDs of all VMs running on XenServer
xe vm-list is-control-domain=false is-a-snapshot=false | grep uuid | cut -d":" -f2 > ${UUIDFILE}

cat $UUIDFILE

if [ ! -f ${UUIDFILE} ]
 then
	echo "No UUID list file found"  >> $LOGFILEVMS
	exit 0
fi

while read VMUUID
do
    VMNAME=`xe vm-list uuid=$VMUUID | grep name-label | cut -d":" -f2 | sed 's/^ *//g'`

    SNAPUUID=`xe vm-snapshot uuid=$VMUUID new-name-label="SNAPSHOT-$VMUUID-$DATE"`

    xe template-param-set is-a-template=false ha-always-run=false uuid=${SNAPUUID}

    xe vm-export vm=${SNAPUUID} filename="$BACKUPPATH/$XSNAME-$VMNAME-$DATE.xva"

    echo "$DATE backup $XSNAME-$VMNAME-$DATE.xva success "  >> $LOGFILEVMS

    xe vm-uninstall uuid=${SNAPUUID} force=true

done < ${UUIDFILE}

#rm $UUIDFILE

exit 0
