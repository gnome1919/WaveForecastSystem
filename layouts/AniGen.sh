#!/bin/bash

start=`date +%s`

#set -x
#trap read debug

PATH=/home/iwf/Tecplot360/bin:$PATH; export PATH

cd /archive/Daily_Archive/layouts

today=`date +%Y%m%d`
#today=20160525

sed -i "9 s:.*:\$\!READDATASET  '/archive/Daily_Archive/PG-IO/$today/Indian/Indian.plt':" Indian_Animation.mcr
imageno=00
for line in {29..164..9}; do
	imageno=$(printf "%02d" "${imageno#0}")	
	sed -i "$line s:.*:\$\!EXPORTSETUP EXPORTFNAME = '/archive/Daily_Archive/PG-IO/$today/Indian/$imageno.png':" Indian_Animation.mcr
	imageno=$((${imageno#0}+6))
done

sed -i "9 s:.*:\$\!READDATASET  '/archive/Daily_Archive/Caspian/$today/wave.plt':" Caspian_Animation.mcr
imageno=00
for line in {29..164..9}; do
	imageno=$(printf "%02d" "${imageno#0}")	
	sed -i "$line s:.*:\$\!EXPORTSETUP EXPORTFNAME = '/archive/Daily_Archive/Caspian/$today/$imageno.png':" Caspian_Animation.mcr
	imageno=$((${imageno#0}+6))
done

sed -i "9 s:.*:\$\!READDATASET  '/archive/Daily_Archive/PG-IO/$today/Persian/Persian.plt':" Persian_Animation.mcr
imageno=00
for line in {29..164..9}; do
	imageno=$(printf "%02d" "${imageno#0}")	
	sed -i "$line s:.*:\$\!EXPORTSETUP EXPORTFNAME = '/archive/Daily_Archive/PG-IO/$today/Persian/$imageno.png':" Persian_Animation.mcr
	imageno=$((${imageno#0}+6))
done


tec360 -b -p Caspian_Animation.mcr
tec360 -b -p Indian_Animation.mcr
tec360 -b -p Persian_Animation.mcr

convert -delay 100 -loop 0 /archive/Daily_Archive/PG-IO/$today/Indian/*.png Indian.gif
convert -delay 100 -loop 0 /archive/Daily_Archive/Caspian/$today/*.png Caspian.gif
convert -delay 100 -loop 0 /archive/Daily_Archive/PG-IO/$today/Persian/*.png Persian.gif

##curl -T "{Indian.gif,Caspian.gif,Persian.gif}" -u hoshdar:gosvidar_i^21 ftp://172.16.1.12
#curl -T "Indian.gif" -u hoshdar:gosvidar_i^21 ftp://172.16.1.12
#curl -T "Persian.gif" -u hoshdar:gosvidar_i^21 ftp://172.16.1.12
#curl -T "Caspian.gif" -u hoshdar:gosvidar_i^21 ftp://172.16.1.12
scp Indian.gif Persian.gif Caspian.gif iwf@192.168.1.184:~/Wave_Forecast_Daily_Files/

##curl -T "{/archive/Daily_Archive/PG-IO/$today/Indian/indian_plot.pdf,\
##/archive/Daily_Archive/PG-IO/$today/Persian/persian_plot.pdf,\
##/archive/Daily_Archive/Caspian/$today/caspian_plot.pdf}" -u hoshdar:gosvidar_i^21 ftp://172.16.1.12
#curl -T "/archive/Daily_Archive/PG-IO/$today/Indian/indian_plot.pdf" -u hoshdar:gosvidar_i^21 ftp://172.16.1.12
#curl -T "/archive/Daily_Archive/PG-IO/$today/Persian/persian_plot.pdf" -u hoshdar:gosvidar_i^21 ftp://172.16.1.12
#curl -T "/archive/Daily_Archive/Caspian/$today/caspian_plot.pdf" -u hoshdar:gosvidar_i^21 ftp://172.16.1.12
scp "/archive/Daily_Archive/PG-IO/$today/Indian/indian_plot.pdf" "/archive/Daily_Archive/PG-IO/$today/Persian/persian_plot.pdf" "/archive/Daily_Archive/Caspian/$today/caspian_plot.pdf" iwf@192.168.1.184:~/Wave_Forecast_Daily_Files/

mv -f Indian.gif /archive/Daily_Archive/PG-IO/$today/Indian/
mv -f Caspian.gif /archive/Daily_Archive/Caspian/$today/
mv -f Persian.gif /archive/Daily_Archive/PG-IO/$today/Persian/
rm -f /archive/Daily_Archive/PG-IO/$today/Indian/*.png
rm -f /archive/Daily_Archive/Caspian/$today/*.png
rm -f /archive/Daily_Archive/PG-IO/$today/Persian/*.png

end=`date +%s`
runtime=$((end-start))
echo "**********************************"
echo "* Elapsed Time: $runtime Seconds *"
echo "**********************************"

mv -f ./CRON.log /archive/Daily_Archive/PG-IO/$today/AniGen.log
exit 0
