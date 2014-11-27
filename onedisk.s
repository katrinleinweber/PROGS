#! /bin/csh
#echo Insert new stiffy. Stiffy should be empty.
#echo -n Press \<ctrl-D\> when ready.
# cat - >> /dev/null
echo \ 
mount /stiffy
# rm -f /stiffy/*
cat - << END > tmp/zot.tmp
BEGIN{ total=0; ds=1400000;
}
(\$1!~/d/)&&(NF==9)&&(\$9!~/\.s\$/){
	if (total+\$5<ds){ print \$9; total+=\$5}
}
END

ls -lS | awk -f tmp/zot.tmp > tmp/zot.fil
# cat tmp/zot.fil
tar -cvzf tmp/trash.gz -T tmp/zot.fil
cp -i tmp/trash.gz /stiffy
mv -i `cat tmp/zot.fil` DONE
# rm tmp/trash.gz tmp/zot.fil tmp/zot.tmp
sync
umount /stiffy
echo Stiffy is dismounted, you may remove it.

