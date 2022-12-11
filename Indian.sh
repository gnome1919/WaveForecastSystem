#!/bin/bash

#set -x
#trap read debug

#echo "THIS IS A CRON TEST VIA Indian.sh" | mail -s "CRON TEST" iwf@iwf1

start=`date +%s`

echo "********************************************"
echo "* Starting Time: `date +%T%t%x` *"
echo "********************************************"
echo ' '
echo ' '

source /opt/intel/parallel_studio_xe_2015/psxevars.sh intel64 >/dev/null
export INTEL_LICENSE_FILE=/opt/intel/licenses
export PATH=/home/iwf/curl/bin:$PATH
export LD_LIBRARY_PATH=/home/iwf/curl/lib:$LD_LIBRARY_PATH

source /usr/share/Modules/init/bash
module load Forecast

cd /archive/Daily_Archive/PG-IO

#clear

#bold=`tput bold`
#normal=`tput sgr0`

echo ' '
echo ' Wavewatch© Input Data Generator for Indian Ocean'
echo ' Copyleft 2021'
echo ' Version 4.0'
echo ' By Farrokh Alavian Ghavanini'
echo ' '
echo ' '
echo '                    ***********************************'
echo '                  ***   Downloading Global Wind Data  ***'
echo '                  ***       from NOAA FTP Server      ***'
echo '                    ***********************************'
echo ' '



#https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p50.pl?file=gfs.t00z.pgrb2full.0p50.f000&lev_10_m_above_ground=on&var_UGRD=on&var_VGRD=on&leftlon=0&rightlon=360&toplat=90&bottomlat=-90&dir=%2Fgfs.20210407%2F00%2Fatmos
#https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p50.pl?file=gfs.t00z.pgrb2full.0p50.f000&lev_10_m_above_ground=on&var_UGRD=on&var_VGRD=on&leftlon=0&rightlon=360&toplat=90&bottomlat=-90&dir=%2Fgfs.20210407%2F00

ftpdir=/pub/data/nccf/com/gfs/prod
filecon=z.pgrb2full.0p50.f
server=ftp.ncep.noaa.gov
today=`date +%Y%m%d`
#today=20160210
dir=$today;
hour=`date -u +%H`
OK=$NULL

#if [ "$hour" -lt "6" ]; then
#		echo "Current time in GMT is: `date -u +%R` "
#		echo -n "Continue anyway? [y/n] "
#		read OK
#		
#		until [ "$OK" = 'y' ] || [ "$OK" = 'Y' ] || \
#    			 [ "$OK" = 'n' ] || [ "$OK" = 'N' ]
#		do
#	 		 echo -n "Continue anyway? [y/n] "
#	 		 read OK
#	 	done
#	 	
#	 		 if [ "$OK" = 'n' ] || [ "$OK" = 'N' ]; then
#			 	echo -e "\nABORTED BY USER!\n"
#			 else
#			 	echo "WARNING! The data to be downloaded may be incomplete."
#			 fi
#	else
#		echo "Current time in GMT is: `date -u +%R` ... seems OK!"		
#fi

echo "Current time in GMT is: `date -u +%R` "

if [ -d "$dir" ]; then
		echo "$dir directory exists! Backing up existing directory..."
		mv -v $dir $dir.bak
		echo "Making $dir directory"
		mkdir $dir
	else
		echo "Making $dir directory"
		mkdir $dir
fi

for time in {00..96..3};
	do
		filename=gfs.t00$filecon$time
		serverfilename=gfs.t00$filecon$(printf "%03d" "${time#0}")
		url="https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p50.pl?file=$serverfilename&lev_10_m_above_ground=on&var_UGRD=on&var_VGRD=on&leftlon=0&rightlon=360&toplat=90&bottomlat=-90&dir=%2Fgfs."$today"%2F00%2Fatmos"
		echo "--> Downloading $filename:"
		ret=1
		tries=1
		while [[ "$ret" != 0 ]] && [[ "$tries" -le 10 ]]; do
			curl -m 60 --retry 10 --retry-delay 5 -L $url --output ./$dir/$filename.grib2
			ret=$?
			tries=$(($tries+1))
			sleep 10
		done
		if [ "$ret" != "0" ]; then
			echo " *** WARNING!!! Couldn't Download $filename, File Skipped ***"
			wgrib2 ./$dir/$filename.grib2 -spread ./$dir/$time.txt
#			cat ./$dir/$time.txt >> ./$dir/wind-gfs.dat
			echo ' '
		else
			echo -e "     Converting $filename to spreadsheet format..."
			wgrib2 ./$dir/$filename.grib2 -spread ./$dir/$time.txt
#			echo "Adding downloaded data to \"wind-gfs.dat\"..."
#			cat ./$dir/$time.txt >> ./$dir/wind-gfs.dat
			echo ' ';
		fi
done

mkdir ../Caspian/$dir
cp ./$dir/*.txt ../Caspian/$dir
cp ./$dir/*.grib2 ../Caspian/$dir

#mkdir ../Persian/$dir
#cp ./$dir/*.txt ../Persian/$dir
#cp ./$dir/*.grib2 ../Persian/$dir

echo ' '
echo '                    ***********************************'
echo '                  ***        Download Completed!      ***'
echo '                    ***********************************'
echo ' '
echo ' '


echo " --> Creating Input Wind File..."

for time in {00..96..3}; do
	
	echo "     Processing gfs.t00$filecon$(printf "%03d" "${time#0}").grib2..."	
	if [ $time == "00" ]; then
		sed 's:lon,lat,[A-Z]* 10 m above ground d=\([0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\).*:\1:' ./$dir/$time.txt > ./$dir/temp.txt
		date1=`sed -n 1p ./$dir/temp.txt`
	fi
	
	
	if [ $time == "24" ]; then
		date1=`date -d "$date1 +1 day" +%Y%m%d`
	elif [ $time == "48" ]; then
		date1=`date -d "$date1 +1 day" +%Y%m%d`
	elif [ $time == "72" ]; then
		date1=`date -d "$date1 +1 day" +%Y%m%d`
	elif [ $time == "96" ]; then
		date1=`date -d "$date1 +1 day" +%Y%m%d`
	fi
	
	
	if [ $time -ge "00" ] && [ $time -le "21" ]; then	
		time2=$time
	elif [ $time -gt "21" ] && [ $time -le "45" ]; then	
		time2=$(($time-24))
		time2=$(printf "%02d" $time2)
	elif [ $time -gt "45" ] && [ $time -le "69" ]; then
		time2=$(($time-48))
		time2=$(printf "%02d" $time2)
	elif [ $time -gt "69" ] && [ $time -le "93" ]; then 
		time2=$(($time-72))
		time2=$(printf "%02d" $time2)
	elif [ $time == "96" ]; then 
		time2=$(($time-96))
		time2=$(printf "%02d" $time2)
	fi
	
		
	echo -e "$date1\t"$time2"0000" >> ./IO-wind.dat
	
	
	for (( j = 1; j <= 2; j++ )); do
		if [ $j == "1" ]; then
			sed -n '/lon,lat,UGRD/,/lon,lat,VGRD/p' ./$dir/$time.txt > ./$dir/vel_sep.txt
		else
			sed -n '/lon,lat,VGRD/,/359.500000,90.000000/p' ./$dir/$time.txt > ./$dir/vel_sep.txt
		fi
		line=173602
		for (( i = 1; i <= 92;  i++ )); do
			sed -n "$line","$(($line+110))"p ./$dir/vel_sep.txt > ./$dir/col.txt
			sed 's:[0-9]*.[0-9]*,[-0-9]*.[0-9]*,::' ./$dir/col.txt > ./$dir/col_trim.txt	
			awk -F"\n" 'NR==1{a=sprintf("%10.2f", $1); next}{a=sprintf("%s%10.2f", a,$1);}END{print a}' ./$dir/col_trim.txt >> ./IO-wind.dat
			line=$(($line-720))
		done
	done
done
echo 'Done!'
echo ' '
echo ' '

echo " --> Preparing Wind Plot file for Tecplot-360©..."

date1=`sed -n 1p ./$dir/temp.txt`

echo 'TITLE = "Persian Gulf-Gulf of Oman-Indian Ocean"' > ./$dir/wind.plt
echo 'VARIABLES = "N" , "X" , "Y" , "u" , "v"' >> ./$dir/wind.plt

i=1
for time in {00..96..3}; do
	
	filename=gfs.t00$filecon$time

	if [ $time == "00" ]; then
		date1=`date -d "$date1 " +%a." "%d" "%b" "%Y`
	elif [ $time == "24" ]; then
		date1=`date -d "$date1 +1 day" +%a." "%d" "%b" "%Y`
	elif [ $time == "48" ]; then
		date1=`date -d "$date1 +1 day" +%a." "%d" "%b" "%Y`
	elif [ $time == "72" ]; then
		date1=`date -d "$date1 +1 day" +%a." "%d" "%b" "%Y`
	elif [ $time == "96" ]; then
		date1=`date -d "$date1 +1 day" +%a." "%d" "%b" "%Y`
	fi
	
	
	if [ $time -ge "00" ] && [ $time -le "21" ]; then	
		time2=$time
	elif [ $time -gt "21" ] && [ $time -le "45" ]; then	
		time2=$(($time-24))
		time2=$(printf "%02d" $time2)
	elif [ $time -gt "45" ] && [ $time -le "69" ]; then
		time2=$(($time-48))
		time2=$(printf "%02d" $time2)
	elif [ $time -gt "69" ] && [ $time -le "93" ]; then 
		time2=$(($time-72))
		time2=$(printf "%02d" $time2)
	elif [ $time == "96" ]; then 
		time2=$(($time-96))
		time2=$(printf "%02d" $time2)
	fi
	
	
	echo "     Processing Wind Data for $date1 @ $time2:00..."
	echo 'TEXT' >> ./$dir/wind.plt
	echo 'CS=FRAME' >> ./$dir/wind.plt
	echo 'X=31	Y=80' >> ./$dir/wind.plt
	echo "ZN=$i" >> ./$dir/wind.plt
	echo 'C=BLACK' >> ./$dir/wind.plt
	echo 'HU=POINT' >> ./$dir/wind.plt
	echo 'LS=1	AN=LEFT' >> ./$dir/wind.plt
	echo 'F=TIMES-BOLD' >> ./$dir/wind.plt
	echo 'H=16	A=0' >> ./$dir/wind.plt
	echo 'T="Forecast for '$time2' UTC '$date1'"' >> ./$dir/wind.plt
	echo 'ZONE' >> ./$dir/wind.plt
	echo "T=\"$i\" , I=95 , J=49 , K=1 , F=POINT" >> ./$dir/wind.plt
	sed -i '22 s:.*:  a  = addfile("'./$dir'/'$filename'.grib2","r"):' wind.ncl
	ncl wind.ncl >> ./$dir/ncl.log
	cat ncl.tmp >> ./$dir/wind.plt
	i=$(($i+1))
	
done

echo 'Done!'
echo ' '
echo ' '


echo " --> Preparing Wavewatch© Input Files..."

date1=`sed -n 1p ./$dir/temp.txt`
date2=`date -d "$date1 +4 day" +%Y%m%d`
date_res=`date -d "$date1 +1 day" +%Y%m%d`

sed -i "87 s:.*:   $date1 000000   $date2 000000:" ww3_multi.inp
sed -i "101 s:.*:   $date1 000000   3600   $date2 000000:" ww3_multi.inp
sed -i "116 s:.*:   $date1 000000   3600   $date2 000000:" ww3_multi.inp
sed -i "123528 s:.*:   $date1 000000   0   $date2 000000:" ww3_multi.inp
sed -i "123530 s:.*:   $date_res 000000   1   $date_res 000000:" ww3_multi.inp
sed -i "123532 s:.*:   $date1 000000   0   $date2 000000:" ww3_multi.inp
sed -i "123534 s:.*:   $date1 000000   0   $date2 000000:" ww3_multi.inp
echo 'Done!'
echo ' '
echo ' '

echo " --> Running Wavewatch© Field Preprocessor for multi_grid Shell..."
mv -fv ./IO-wind.dat ./Wind_Grid
cd ./Wind_Grid
ww3_prep
mv -fv ./wind.ww3 ../wind.Input
cd ..
echo 'Done!'
echo ' '
echo ' '

echo " --> Running Wavewatch© Initial Conditions Program..."
if [[ ! -f ./restart001.Indian || ! -f ./restart001.Persian ]]; then
	cd Indian_Grid
	ww3_strt
	cd ..
	cp -f ./Indian_Grid/restart.ww3 ./restart.Indian

	cd Persian_Grid
	ww3_strt
	cd ..
	cp -f ./Persian_Grid/restart.ww3 ./restart.Persian
	echo ' '
else
	stat -c %y restart001.Indian > time_res_indian.tmp
	stat -c %y restart001.Persian > time_res_persian.tmp
	sed -i 's:\([0-9]*-[0-9]*-[0-9]*\).*:\1:' time_res_indian.tmp
	sed -i 's:\([0-9]*-[0-9]*-[0-9]*\).*:\1:' time_res_persian.tmp
	ydate=`date +%Y-%m-%d -d "yesterday"`
	indian_res_date=`sed -n 1p time_res_indian.tmp`
	persian_res_date=`sed -n 1p time_res_persian.tmp`
	if [[ "$ydate" == "$indian_res_date" && "$ydate" == "$persian_res_date" ]]; then
		mv -fv restart001.Indian restart.Indian
		mv -fv restart001.Persian restart.Persian
		echo ' '
	else
		echo " *** WARNING!!! The current \"restart\" file(s) is not applicable! ***"
		echo "     Continuing without \"restart\" file..."
		echo ' '
		echo ' '
		echo " --> Running Wavewatch© Initial Conditions Program..."
		cd Indian_Grid
		ww3_strt
		cd ..
		cp -f ./Indian_Grid/restart.ww3 ./restart.Indian

		cd Persian_Grid
		ww3_strt
		cd ..
		cp -f ./Persian_Grid/restart.ww3 ./restart.Persian
		echo ' '
		echo ' '
	fi
fi

echo " --> Running Wavewatch© multi_grid Shell..."
#mpiexec -n 8 ww3_shel
mpiexec.hydra -n 8 ww3_multi
echo ' '
echo ' '

echo " --> Running Wavewatch© Point Output Post-Processor..."
mv -fv ./out_pnt.Output  ./Output_Grid/out_pnt.ww3
cd Output_Grid
echo ' '
echo ' '

echo "     Creating Point Output for the SWAN Coarse-Grid model..."
cp -fv ww3_outp.inp.swan ww3_outp.inp
sed -i "7 s:.*:   $date1 000000   3600   96:" ww3_outp.inp
ww3_outp
rm -fv ww3_outp.inp
mv -fv *.spc ../SWAN/Coarse
echo ' '
echo ' '

echo "     Creating Point Output for the Persian Gulf Grid..."
cp -fv ww3_outp.inp.per ww3_outp.inp
sed -i "7 s:.*:   $date1 000000   3600   96:" ww3_outp.inp
ww3_outp
rm -fv ww3_outp.inp
echo ' '
echo ' '

echo "     Creating Point Output for the Indian Ocean Grid..."
cp -fv ww3_outp.inp.ind ww3_outp.inp
sed -i "7 s:.*:   $date1 000000   3600   96:" ww3_outp.inp
ww3_outp
rm -fv ww3_outp.inp
cd ..
echo ' '
echo ' '

echo " --> Preparing Wave Plot file for Tecplot-360©..."
echo ' '
echo ' '
echo "     Processing Wave Data for the Persian Gulf..."
cp ./Output_Grid/tab33.ww3 ./tab33.tmp

sl=6
for (( i = 1; i <= 96; i++ )); do
	echo "     Processing Timestep $(($i-1))..."
	sed -n "$sl","$(($sl+54399))"p ./tab33.tmp > ./tab33_2.tmp
	./tab33_mod
	cat ./tab33.mod >> ./tab33.final
	rm -f tab33.mod
	sl=$(($sl+54407))
done
echo ' '
echo ' '

date1=`sed -n 1p ./$dir/temp.txt`

echo 'TITLE = "Wave Graphs for the Persian Gulf"' > ./$dir/Persian.plt
echo 'VARIABLES = "X" , "Y" , "Hs" , "u" , "v" , "Mask"' >> ./$dir/Persian.plt

i=1
sl=1

for time in {00..95..1}; do


	if [ $time == "00" ]; then
		date1=`date -d "$date1" +%a." "%d" "%b" "%Y`
	elif [ $time == "24" ]; then
		date1=`date -d "$date1 +1 day" +%a." "%d" "%b" "%Y`
	elif [ $time == "48" ]; then
		date1=`date -d "$date1 +1 day" +%a." "%d" "%b" "%Y`
	elif [ $time == "72" ]; then
		date1=`date -d "$date1 +1 day" +%a." "%d" "%b" "%Y`
	fi
	
	
	if [ $time -ge "00" ] && [ $time -le "23" ]; then	
		time2=$time
	elif [ $time -gt "23" ] && [ $time -le "47" ]; then	
		time2=$(($time-24))
		time2=$(printf "%02d" $time2)
	elif [ $time -gt "47" ] && [ $time -le "71" ]; then
		time2=$(($time-48))
		time2=$(printf "%02d" $time2)
	elif [ $time -gt "71" ] && [ $time -le "95" ]; then 
		time2=$(($time-72))
		time2=$(printf "%02d" $time2)
	fi
	
	
	echo "     Creating Wave Plot for $date1 @ $time2:00..."
	echo 'TEXT' >> ./$dir/Persian.plt
	echo 'CS=FRAME' >> ./$dir/Persian.plt
	echo 'X=32	Y=92.5' >> ./$dir/Persian.plt
	echo "ZN=$i" >> ./$dir/Persian.plt
	echo 'C=BLACK' >> ./$dir/Persian.plt
	echo 'HU=POINT' >> ./$dir/Persian.plt
	echo 'LS=1	AN=LEFT' >> ./$dir/Persian.plt
	echo 'F=TIMES-BOLD' >> ./$dir/Persian.plt
	echo 'H=16	A=0' >> ./$dir/Persian.plt
	echo 'T="Forecast for '$time2' UTC '$date1'"' >> ./$dir/Persian.plt
	echo 'ZONE' >> ./$dir/Persian.plt
	echo "T=\"$i\" , I=320 , J=170 , K=1 , F=POINT" >> ./$dir/Persian.plt
	sed -n "$sl","$(($sl+54399))"p ./tab33.final >> ./$dir/Persian.plt
	i=$(($i+1))
	sl=$(($sl+54400))
	
done

echo 'Done!'
echo ' '
echo ' '

echo " --> Processing Wave Data for the Indian Ocean..."
cp ./Output_Grid/tab44.ww3 ./tab44.tmp

sl=6
for (( i = 1; i <= 96; i++ )); do
	echo "     Processing Timestep $(($i-1))..."
	sed -n "$sl","$(($sl+69004))"p ./tab44.tmp > ./tab44_2.tmp
	./tab44_mod
	cat ./tab44.mod >> ./tab44.final
	rm -f tab44.mod
	sl=$(($sl+69012))
done
echo ' '
echo ' '

date1=`sed -n 1p ./$dir/temp.txt`

echo 'TITLE = "Wave Graphs for the Indian Ocean"' > ./$dir/Indian.plt
echo 'VARIABLES = "X" , "Y" , "Hs" , "u" , "v" , "Mask"' >> ./$dir/Indian.plt

i=1
sl=1

for time in {00..95..1}; do


	if [ $time == "00" ]; then
		date1=`date -d "$date1" +%a." "%d" "%b" "%Y`
	elif [ $time == "24" ]; then
		date1=`date -d "$date1 +1 day" +%a." "%d" "%b" "%Y`
	elif [ $time == "48" ]; then
		date1=`date -d "$date1 +1 day" +%a." "%d" "%b" "%Y`
	elif [ $time == "72" ]; then
		date1=`date -d "$date1 +1 day" +%a." "%d" "%b" "%Y`
	fi
	
	
	if [ $time -ge "00" ] && [ $time -le "23" ]; then	
		time2=$time
	elif [ $time -gt "23" ] && [ $time -le "47" ]; then	
		time2=$(($time-24))
		time2=$(printf "%02d" $time2)
	elif [ $time -gt "47" ] && [ $time -le "71" ]; then
		time2=$(($time-48))
		time2=$(printf "%02d" $time2)
	elif [ $time -gt "71" ] && [ $time -le "95" ]; then 
		time2=$(($time-72))
		time2=$(printf "%02d" $time2)
	fi
	
	
	echo "     Creating Wave Plot for $date1 @ $time2:00..."
	echo 'TEXT' >> ./$dir/Indian.plt
	echo 'CS=FRAME' >> ./$dir/Indian.plt
	echo 'X=31.50	Y=92.5' >> ./$dir/Indian.plt
	echo "ZN=$i" >> ./$dir/Indian.plt
	echo 'C=BLACK' >> ./$dir/Indian.plt
	echo 'HU=POINT' >> ./$dir/Indian.plt
	echo 'LS=1	AN=LEFT' >> ./$dir/Indian.plt
	echo 'F=TIMES-BOLD' >> ./$dir/Indian.plt
	echo 'H=16	A=0' >> ./$dir/Indian.plt
	echo 'T="Forecast for '$time2' UTC '$date1'"' >> ./$dir/Indian.plt
	echo 'ZONE' >> ./$dir/Indian.plt
	echo "T=\"$i\" , I=373 , J=185 , K=1 , F=POINT" >> ./$dir/Indian.plt
	sed -n "$sl","$(($sl+69004))"p ./tab44.final >> ./$dir/Indian.plt
	i=$(($i+1))
	sl=$(($sl+69005))
	
done

echo 'Done!'
echo ' '
echo ' '


echo " --> Creating Time Series Plots..."
date1=`sed -n 1p ./$dir/temp.txt`
cd ./Output_Grid
cp -fv ./ww3_outp.inp.ser ./ww3_outp.inp
sed -i "7 s:.*:   $date1 000000   3600   96:" ww3_outp.inp
ww3_outp

sl=6
for (( i = 1; i <= 96; i++ )); do

	sed -n "$sl","$(($sl+14))"p ./tab55.ww3 >> ./tab55.tmp
	sl=$(($sl+22))
done
echo ' '
echo ' '

awk '{ print $3}' tab55.tmp > gen.tmp

sl=1
for (( i = 1; i <= 96; i++ )); do
	echo "     Processing Timestep $(($i-1))..."
	sed -n "$sl"p ./gen.tmp >> 23790.txt		#St.IV
	sed -n "$(($sl+1))"p ./gen.tmp >> 24149.txt	#Abumusa
	sed -n "$(($sl+2))"p ./gen.tmp >> 28287.txt	#Kish
	sed -n "$(($sl+3))"p ./gen.tmp >> 29291.txt	#Qeshm
	sed -n "$(($sl+4))"p ./gen.tmp >> 30580.txt	#Hormoz
	sed -n "$(($sl+5))"p ./gen.tmp >> 31116.txt	#St.III
	sed -n "$(($sl+6))"p ./gen.tmp >> 34978.txt	#Asaluyeh
	sed -n "$(($sl+7))"p ./gen.tmp >> 41647.txt	#St.II
	sed -n "$(($sl+8))"p ./gen.tmp >> 43903.txt	#Bushehr
	sed -n "$(($sl+9))"p ./gen.tmp >> 46435.txt	#St.I

	sed -n "$(($sl+10))"p ./gen.tmp >> 93457.txt	#St.VII
	sed -n "$(($sl+11))"p ./gen.tmp >> 100897.txt	#St.VI
	sed -n "$(($sl+12))"p ./gen.tmp >> 103856.txt	#St.V
	sed -n "$(($sl+13))"p ./gen.tmp >> 105365.txt	#Chabahar
	sed -n "$(($sl+14))"p ./gen.tmp >> 106090.txt	#Jask
	sl=$(($sl+15))
done

rm -fv gen.txt
date1=`sed -n 1p ../$dir/temp.txt`
date1=`date -d "$date1 -1 day" +%Y/%m/%d`
for j in {1..4}; do
	date1=`date -d "$date1 +1 day" +%Y/%m/%d`
	echo -e "$date1 \n\n" >> gen.txt
	for k in {03..21..03}; do
		echo -e "$k \n\n" >> gen.txt			
	done
done
echo ' '
echo ' '

echo "     Generating Time Series Plots for the Persian Gulf..."
for i in 43903 34978 28287 24149 29291 30580 23790 31116 41647 46435; do
	paste $i.txt gen.txt > $i.tmp
	rm $i.txt
done

mkdir ../$dir/Persian ../$dir/Indian
cat points.dat.per | while read a b; do
	sed -i "22 s:.*:set output \"$a.ps\":" plot.gp.per
	sed -i "124 s:.*:set x2label \"$a\":" plot.gp.per
	sed -i "157 s/.*/plot \"$b.tmp\" u 1:xticlabel(2) w l ls 1 smooth csplines, \"\" u 1:xticlabel(2) w p ls 1/" plot.gp.per
	gnuplot ./plot.gp.per
	ps2pdf14 ./$a.ps ../$dir/Persian/$a.pdf
	mv ./$a.ps ../$dir/Persian
done
pdftk ../$dir/Persian/*.pdf cat output ../$dir/Persian/pdftk.pdf
pdftk ../$dir/Persian/pdftk.pdf cat 1-endE output ../$dir/Persian/persian_plot.pdf
rm -f ../$dir/Persian/pdftk.pdf
echo 'Done!'
echo ' '
echo ' '

echo "     Generating Time Series Plots for the Indian Ocean..."
for i in 106090 105365 103856 100897 93457; do
	paste $i.txt gen.txt > $i.tmp
	rm $i.txt
done

cat points.dat.ind | while read a b; do
	sed -i "22 s:.*:set output \"$a.ps\":" plot.gp.ind
	sed -i "124 s:.*:set x2label \"$a\":" plot.gp.ind
	sed -i "157 s/.*/plot \"$b.tmp\" u 1:xticlabel(2) w l ls 1 smooth csplines, \"\" u 1:xticlabel(2) w p ls 1/" plot.gp.ind
	gnuplot ./plot.gp.ind
	ps2pdf14 ./$a.ps ../$dir/Indian/$a.pdf
	mv ./$a.ps ../$dir/Indian
done
pdftk ../$dir/Indian/*.pdf cat output ../$dir/Indian/pdftk.pdf
pdftk ../$dir/Indian/pdftk.pdf cat 1-endE output ../$dir/Indian/indian_plot.pdf
rm -f ../$dir/Indian/pdftk.pdf
rm -f ./ww3_outp.inp
cd ..
echo 'Done!'
echo ' '
echo ' '

echo " --> Doing Some Housekeeping, Please be Patient..."
###rm -fv test*.ww3 fort.20
rm -f wind.Input out_grd.* *.final *.tmp restart.*
rm -f ./$dir/*.txt
echo ' '
echo "     Compressing Data..."
tar --remove-files -cvjSf ./$dir/GFS_wind_grib.tar.bz2 ./$dir/*.grib2
mv -f ./$dir/Persian.plt ./$dir/Persian/
mv -f ./$dir/Indian.plt ./$dir/Indian/
mv -f ./log.Indian ./$dir/Indian/
mv -f ./log.Persian ./$dir/Persian/
mv -f ./log.mww3 ./$dir/
cp -f ./Wind_Grid/IO-wind.dat ./SWAN/Coarse
cp -f ./Wind_Grid/IO-wind.dat ./SWAN/Nested
mv -f ./Wind_Grid/IO-wind.dat ./$dir/
cp -f ./restart001.Persian ./$dir/Persian/restart.Persian
cp -f ./restart001.Indian ./$dir/Indian/restart.Indian
rm -f ./Output_Grid/*.tmp ./Output_Grid/gen.txt ./Output_Grid/tab55.ww3 ./Output_Grid/out_pnt.ww3
mv -f ./Output_Grid/tab33.ww3 ./$dir/Persian/
mv -f ./Output_Grid/tab44.ww3 ./$dir/Indian/
rm -f ./$dir/wind-gfs.dat
tar --remove-files -cvjSf ./$dir/Persian/ww3_data.tar.bz2 ./$dir/Persian/restart.Persian ./$dir/Persian/tab33.ww3
tar --remove-files -cvjSf ./$dir/Indian/ww3_data.tar.bz2 ./$dir/Indian/restart.Indian ./$dir/Indian/tab44.ww3

echo '/*------------------Done!-----------------*/'
echo ' '
echo ' '

end=`date +%s`
runtime=$((end-start))
echo "******************************"
echo "*   Elapsed Time: $runtime Seconds  *"
echo "******************************"

mv -f ./CRON.log ./$dir/$dir.log
exit 0
