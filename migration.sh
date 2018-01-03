for i in ` cat liste.txt` 
do
cat $i | sed -e 's/192\.168\.1\.86/ibs\.oasix\.fr/' >temp.pl
 mv temp.pl $i
echo $i
done
