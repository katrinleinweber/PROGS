#!/bin/zsh
function unmount
{
	if ( grep stiffy /etc/mtab > /dev/null ) ; then 
		echo "Unmounting /dev/fd0" 
		umount /stiffy 
	fi
}
function newdisk
{
	unmount
#	if ( grep stiffy /etc/mtab > /dev/null ) ; then ; umount /stiffy ; fi
	echo 'New Disk'
	read
	echo 'Formatting...'
	mformat a:
	mount /stiffy
}
newdisk
FILES=($*)
for f in ${~FILES:=./*}
do
	diskfree=`df /stiffy | awk '/stiffy/{print $4}'`
	filesize=$((`ls -l $f | awk '{print $5}'`/1024))
	if [ $filesize -gt $diskfree ] ; then ; newdisk ; fi
	echo "Copying..."
	cp -i $f /stiffy && echo "Copied $f"
done

unmount
# if ( grep stiffy /etc/mtab > /dev/null ) ; then ; umount /stiffy ; fi

