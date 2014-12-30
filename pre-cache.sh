#!/bin/bash

# Author:: Yossi Ovadia ( jabadia@gmail.com ) 
#
# This script will monitor rbd image pool for newly created / intreduced glance image and will convert it into the _base dir
# in order to save time in the first boot of a VM via Nova.
#
#


LOGFILE=/root/pre-cache.log
while [ 0 ] ; do
    PATH="/cloudfs/nova/_base/"
    for image in `/usr/bin/rbd ls -p images`; do
        for convert in `echo -n $image | /usr/bin/sha1sum | /bin/awk '{print $1'}`;do
	    if [ ! -f $PATH$convert ] ; then
               echo "`/bin/date +%m/%d/%Y\ %T` Found New Image - $image" >> $LOGFILE 2>&1
	       /usr/bin/qemu-img convert -f qcow2 -O raw rbd:images/$image $PATH$convert
	       /bin/chown 107:107 $PATH$convert
	       /bin/chmod 644 $PATH$convert
	    fi
        done
    done
    /bin/sleep 1
done
