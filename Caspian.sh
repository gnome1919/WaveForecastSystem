#!/bin/bash

start=`date +%s`

echo "********************************************"
echo "* Starting Time: `date +%T%t%x` *"
echo "********************************************"
echo ' '
echo ' '

#set -x
#trap read debug

source /opt/intel/parallel_studio_xe_2015/psxevars.sh intel64 > /dev/null
export INTEL_LICENSE_FILE=/opt/intel/licenses
export PATH=/home/iwf/curl/bin:$PATH
export LD_LIBRARY_PATH=/home/iwf/curl/lib:$LD_LIBRARY_PATH

source /usr/share/Modules/init/bash
module load Forecast

cd /archive/Daily_Archive/Caspian

#clear

#bold=`tput bold`
#normal=`tput sgr0`

echo ' '
echo " Wavewatch© Input Data Generator for Caspian Sea"
echo ' Copyleft 2016'
echo ' Version 2.0'
echo " By Farrokh Alavian Ghavanini"
echo ' '
echo ' '
#echo '                    ***********************************'
#echo '                  ***   Downloading Global Wind Data  ***'
#echo '                  ***       from NOAA FTP Server      ***'
#echo '                    ***********************************'
#echo ' '

#ftpdir=/pub/data/nccf/com/gfs/prod
filecon=z.pgrb2full.0p50.f
#server=ftp.ncep.noaa.gov
today=`date +%Y%m%d`
#today=20160210
dir=$today;
#hour=`date -u +%H`
#OK=$NULL

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

#if [ -d "$dir" ]; then
#		echo "$dir directory exists! Backing up existing directory..."
#		mv -v $dir $dir.bak
#		echo "Making $dir directory"
#		mkdir $dir
#	else
#		echo "Making $dir directory"
#		mkdir $dir
#fi

#for time in 00 03 06 09 12 15 18 21 24 27 30 33 36 39 42 45 48 51 54 57 60 63 66 69 72 75 78 81 84 87 90 93 96;
#	do
#		filename=gfs.t00$filecon$time.10m.uv.grib2
#		echo "Downloading $filename:"
#		curl -# -m 120 --retry 10 --retry-delay 10 -C - ftp://$server$ftpdir/gfs."$today"00/$filename > ./$dir/$filename
#		echo -e "Converting $filename to spreadsheet format..."
#		wgrib2 ./$dir/$filename -spread ./$dir/$time.txt
#		echo "Adding downloaded data to \"wind-gfs.dat\"..."
#		cat ./$dir/$time.txt >> ./$dir/wind-gfs.dat
#		echo " ";
#done


#echo ' '
#echo '                    *******************************'
#echo '                  ***          Completed!         ***'
#echo '                    *******************************'
#echo ' '
#echo ' '


echo " Creating Input Wind File..."

for time in {00..96..3}; do
	
	echo "Processing gfs.t00$filecon$(printf "%03d" "${time#0}").grib2..."
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
	
		
	echo -e "$date1\t"$time2"0000" >> ./caspian-wind.dat
	
	
	for (( j = 1; j <= 2; j++ )); do
		if [ $j == "1" ]; then
			sed -n '/lon,lat,UGRD/,/lon,lat,VGRD/p' ./$dir/$time.txt > ./$dir/vel_sep.txt
		else
			sed -n '/lon,lat,VGRD/,/359.500000,90.000000/p' ./$dir/$time.txt > ./$dir/vel_sep.txt
		fi
		line=198095
		for (( i = 1; i <= 24;  i++ )); do
			sed -n "$line","$(($line+17))"p ./$dir/vel_sep.txt > ./$dir/col.txt
			sed 's:[0-9]*.[0-9]*,[0-9]*.[0-9]*,::' ./$dir/col.txt > ./$dir/col_trim.txt	
			awk -F"\n" 'NR==1{a=sprintf("%10.2f", $1); next}{a=sprintf("%s%10.2f", a,$1);}END{print a}' ./$dir/col_trim.txt >> ./caspian-wind.dat
			line=$(($line-720))
		done
	done
done
echo 'Done!'
echo ' '
echo ' '


echo " Preparing Wind Plot file for Tecplot-360©..."

date1=`sed -n 1p ./$dir/temp.txt`

echo 'TITLE = "Caspian Sea"' > ./$dir/wind.plt
echo 'VARIABLES = "N" , "X" , "Y" , "u" , "v"' >> ./$dir/wind.plt

i=1
for time in {00..96..3}; do

	filename=gfs.t00$filecon$time
	
	if [ $time == "00" ]; then
		date1=`date -d "$date1" +%a." "%d" "%b" "%Y`
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
	
	
	echo "Processing Wind Data for $date1 @ $time2:00..."
	echo 'TEXT' >> ./$dir/wind.plt
	echo 'CS=FRAME' >> ./$dir/wind.plt
	echo 'X=24.5	Y=87' >> ./$dir/wind.plt
	echo "ZN=$i" >> ./$dir/wind.plt
	echo 'C=BLACK' >> ./$dir/wind.plt
	echo 'HU=POINT' >> ./$dir/wind.plt
	echo 'LS=1	AN=LEFT' >> ./$dir/wind.plt
	echo 'F=TIMES-BOLD' >> ./$dir/wind.plt
	echo 'H=16	A=0' >> ./$dir/wind.plt
	echo 'T="Forecast for '$time2' UTC '$date1'"' >> ./$dir/wind.plt
	echo 'ZONE' >> ./$dir/wind.plt
	echo "T=\"$i\" , I=18 , J=24 , K=1 , F=POINT" >> ./$dir/wind.plt
	sed -i '22 s:.*:  a  = addfile("'./$dir'/'$filename'.grib2","r"):' wind.ncl
	ncl wind.ncl >> ./$dir/ncl.log
	cat ncl.tmp >> ./$dir/wind.plt
	i=$(($i+1))
	
done

echo 'Done!'
echo ' '
echo ' '


echo " Preparing Wavewatch© Input Files..."

date1=`sed -n 1p ./$dir/temp.txt`
date2=`date -d "$date1 +4 day" +%Y%m%d`
date_res=`date -d "$date1 +1 day" +%Y%m%d`

sed -i "19 s:.*:   $date1 000000:" ww3_shel.inp
sed -i "20 s:.*:   $date2 000000:" ww3_shel.inp
sed -i "57 s:.*:   $date1 000000   3600   $date2   000000:" ww3_shel.inp
sed -i "255 s:.*:   $date1 000000   3600   $date2   000000:" ww3_shel.inp
sed -i "36730 s:.*:   $date1 000000   0   $date2   000000:" ww3_shel.inp
sed -i "36737 s:.*:   $date_res 000000   1   $date_res   000000:" ww3_shel.inp
sed -i "36743 s:.*:   $date1 000000   0   $date2   000000:" ww3_shel.inp
sed -i "36748 s:.*:   $date1 000000   0   $date2   000000:" ww3_shel.inp

sed -i "7 s:.*:   $date1 000000   3600.   96:" ww3_outp.inp

echo 'Done!'
echo ' '
echo ' '

echo " Running Wavewatch© Grid Preprocessor..."
ww3_grid

if [ ! -f ./restart001.ww3 ]; then
	echo " Running Wavewatch© Initial Conditions Program..."
	ww3_strt
	echo ' '
else
	stat -c %y restart001.ww3 > time_temp1.txt
	sed 's:\([0-9]*-[0-9]*-[0-9]*\).*:\1:' time_temp1.txt > time_temp2.txt
	ydate=`date +%Y-%m-%d -d "yesterday"`
	sdate=`sed -n 1p time_temp2.txt`
	if [ "$ydate" == "$sdate" ]; then
		mv -fv restart001.ww3 restart.ww3
		echo ' '
	else
		echo "WARNING: The \"restart\" file is not applicable!"
		echo "Continuing without \"restart\" file..."
		echo ' '
		echo ' '
		echo " Running Wavewatch© Initial Conditions Program..."
		ww3_strt
		echo ' '
	fi
fi

echo " Running Wavewatch© Field Preprocessor for the Generic Shell..."
ww3_prep
echo ' '

echo " Running Wavewatch© Generic Shell..."
mpiexec.hydra -n 8 ww3_shel
#mpiexec -n 8 ww3_shel
echo ' '

echo " Running Wavewatch© Point Output Post-Processor..."
ww3_outp
echo ' '
echo ' '

echo " Preparing Wave Plot file for Tecplot-360©..."

cp ./tab33.ww3 ./tab33.tmp

sl=1
sed -i -e 1,5d ./tab33.tmp
for (( i = 1; i <= 96; i++ )); do
	echo " --> Processing Timestep $(($i-1))..."
	sed -n "$sl","$(($sl+16523))"p ./tab33.tmp > ./tab33_2.tmp
	./tab33_mod
	cat ./dry.coo >> ./tab33.mod
	sort -k2 -k1 -n tab33.mod > tab33.sort
	cat ./tab33.sort >> ./tab33.final
	rm -f tab33.mod
	sl=$(($sl+16531))
done


date1=`sed -n 1p ./$dir/temp.txt`

echo 'TITLE = "Wave Graphs for Caspian Sea"' > ./$dir/wave.plt
echo 'VARIABLES = "X" , "Y" , "Hs" , "u" , "v" , "Mask"' >> ./$dir/wave.plt

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
	
	
	echo "Processing Wave Data for $date1 @ $time2:00..."
	echo 'TEXT' >> ./$dir/wave.plt
	echo 'CS=FRAME' >> ./$dir/wave.plt
	echo 'X=27.5	Y=92.5' >> ./$dir/wave.plt
	echo "ZN=$i" >> ./$dir/wave.plt
	echo 'C=BLACK' >> ./$dir/wave.plt
	echo 'HU=POINT' >> ./$dir/wave.plt
	echo 'LS=1	AN=LEFT' >> ./$dir/wave.plt
	echo 'F=TIMES-BOLD' >> ./$dir/wave.plt
	echo 'H=16	A=0' >> ./$dir/wave.plt
	echo 'T="Forecast for '$time2' UTC '$date1'"' >> ./$dir/wave.plt
	echo 'ZONE' >> ./$dir/wave.plt
	echo "T=\"$i\" , I=165 , J=221 , K=1 , F=POINT" >> ./$dir/wave.plt
	sed -n "$sl","$(($sl+36464))"p ./tab33.final >> ./$dir/wave.plt
	i=$(($i+1))
	sl=$(($sl+36465))
	
done

echo 'Done!'
echo ' '
echo ' '

echo "Creating Time Series Plots..."
mv -fv ./tab33.ww3 ./$dir/
cp -fv ./ww3_outp.inp ./ww3_outp.inp.bak
sed -i 13,36476d ./ww3_outp.inp
for i in 314 50 5 26 265 916 1175 1945 2730; do
	sed -i "12 s:.*:           $i:" ww3_outp.inp
	ww3_outp
	sed -i 1,3d ./tab33.ww3
	rm -fv gen.txt
	date1=`sed -n 1p ./$dir/temp.txt`
	date1=`date -d "$date1 -1 day" +%Y/%m/%d`
	for j in {1..4}; do
		date1=`date -d "$date1 +1 day" +%Y/%m/%d`
		echo -e "$date1 \n\n" >> gen.txt
		for k in {03..21..03}; do
			echo -e "$k \n\n" >> gen.txt			
		done
	done
	awk '{ print $5}' tab33.ww3 > gen.tmp
	paste gen.tmp gen.txt > $i.tmp
done

cat points.dat | while read a b; do
	sed -i "22 s:.*:set output \"$a.ps\":" plot.gp
	sed -i "124 s:.*:set x2label \"$a\":" plot.gp
	sed -i "157 s/.*/plot \"$b.tmp\" u 1:xticlabel(2) w l ls 1 smooth csplines, \"\" u 1:xticlabel(2) w p ls 1/" plot.gp
	gnuplot ./plot.gp
	ps2pdf14 ./$a.ps ./$dir/$a.pdf
	mv ./$a.ps ./$dir/
done
pdftk ./$dir/*.pdf cat output ./$dir/pdftk.pdf
pdftk ./$dir/pdftk.pdf cat 1-endE output ./$dir/caspian_plot.pdf
rm -f ./$dir/pdftk.pdf
rm -fv ./ww3_outp.inp
mv -fv ./ww3_outp.inp.bak ./ww3_outp.inp
echo 'Done!'
echo ' '
echo ' '

echo "Some Housekeeping..."
rm -fv test*.ww3 fort.20 mod_def.ww3 wind.ww3 out_grd.ww3 out_pnt.ww3 time_temp1.txt time_temp2.txt tab33.mod tab33.sort tab33.final gen.txt restart.ww3 tab33.ww3
rm -fv *.tmp
rm -fv ./$dir/*.grib2
rm -fv ./$dir/*.txt
rm -fv ./$dir/*.tmp
mv -fv ./log.ww3 ./$dir/
mv -fv ./caspian-wind.dat ./$dir/
cp -fv ./restart1.ww3 ./$dir/restart.ww3
echo '---------Done!---------'
echo ' '
echo ' '

end=`date +%s`
runtime=$((end-start))
echo "******************************"
echo "* Elapsed Time: $runtime Seconds *"
echo "******************************"

mv -fv ./CRON.log ./$dir/$dir.log
#tar --remove-files -cvjSf ./$dir/$dir.tar.bz2 ./$dir/*
exit 0
