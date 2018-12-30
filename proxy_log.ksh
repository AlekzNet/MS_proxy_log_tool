#!/bin/ksh
# Check the logs for the last AGE days only
AGE=1
DIR=`date +'%Y%m%d_%H%M'`
# Logs location (with directories labeled as the proxy servers)
LOGPATH=/home/proxylogs/
LOGS=`find $LOGPATH -type f -mtime -$AGE`
PXS=`echo $LOGS | sed -e 's/ /\n/g' | awk -F/ '{px[$4]++} END {for (i in px) print i;}'`
# Hosts to ignore, e.g. monitors.
MONS='(172\.20\.16\.1|172\.20\.16\.2|172\.20\.2\.10)'
# Proxies to analyse the logs for
PROXIES='10\.1\.2\.27|10\.1\.5\.98'
echo "Saved in $DIR"
mkdir -p $DIR

for px in $PXS
do
  pxlogs=`echo $LOGS | sed -e 's/ /\n/g' | egrep $px`
# If proxy-001 has a different log structure
  if [[ $px == proxy-001 ]]; then
    lines=`zcat $pxlogs | egrep -v '^#' | egrep -v $MONS | egrep -v $PROXIES | awk '{ ip[$4]++} END {for (i in ip) print ip[i]," ", i}' | fgrep -v - |\
        sort -nr | tee $DIR/$px.ip | wc -l`
    mkdir $DIR/$px
    for ip in `awk '{print $2}' $DIR/$px.ip `
 	do
 		zcat $pxlogs | fgrep $ip | awk '{ a=  $3 " " $7; ip[a]++} END {for (i in ip) print ip[i]," ", i}' | sort -nr > $DIR/$px/$ip
 	done
    
#    users=`zcat $pxlogs | egrep -v '^#' | egrep -v $MONS | sed -e 's/\"//g' | awk '{ ip[$3]++} END {for (i in ip) print ip[i]," ", i}' | \
#        sort -nr | tee $DIR/$px.users| wc -l`
  else
    lines=`zcat $pxlogs | egrep -v '^#' | egrep -v $MONS | awk '{ ip[$1]++} END {for (i in ip) print ip[i]," ", i}' | fgrep -v - |\
        sort -nr | tee $DIR/$px.ip | wc -l`
    mkdir $DIR/$px
# If proxy-002 has a different log structure    
 	if [[ $px == proxy-002 ]]; then   
		for ip in `awk '{print $2}' $DIR/$px.ip`
		do
			zcat $pxlogs | fgrep $ip | awk '{ a=  $2 " " $9; ip[a]++} END {for (i in ip) print ip[i]," ", i}' | sort -nr > $DIR/$px/$ip
		done
	else
		for ip in `awk '{print $2}' $DIR/$px.ip`
		do
			zcat $pxlogs | fgrep $ip | awk '{ a=  $2 " " $8; ip[a]++} END {for (i in ip) print ip[i]," ", i}' | sort -nr > $DIR/$px/$ip
		done
	fi
#    users=`zcat $pxlogs | egrep -v '^#' | egrep -v $MONS | sed -e 's/\"//g' | awk '{ ip[$2]++} END {for (i in ip) print ip[i]," ", i}' | \
#        sort -nr | tee $DIR/$px.users | wc -l`
  fi
  echo "$px = $lines client addresses"
done |tee  $DIR/$DIR.stat

echo "Converting to HTML"
./genpxhtml.sh $DIR > $DIR/${DIR}.html
gzip $DIR/${DIR}.html

