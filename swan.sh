#!/bin/bash

start=`date +%s`

echo "********************************************"
echo "* Starting Time: `date +%T%t%x` *"
echo "********************************************"
echo ' '
echo ' '

#set -x
#trap read debug

source /opt/intel/parallel_studio_xe_2015/psxevars.sh intel64 >/dev/null
export INTEL_LICENSE_FILE=/opt/intel/licenses
export PATH=/home/iwf/curl/bin:$PATH
export LD_LIBRARY_PATH=/home/iwf/curl/lib:$LD_LIBRARY_PATH

source /usr/share/Modules/init/bash
module load Forecast

cd /archive/Daily_Archive/PG-IO/SWAN/Coarse

today=`date +%Y%m%d`
#today=20160916
dir=$today;
hour=`date -u +%H`

echo " --> Running SWAN Coarse-Grid Model for the next 96 hours..."
cp -fv INPUT.swn.original INPUT.swn
#date1=`sed -n 1p ./$dir/temp.txt`
date1=$today
date2=`date -d "$date1 +4 day" +%Y%m%d`
date3=`date -d "$date1" +%y%m%d00`

sed -i "35 s:.*:\t\tdxinp=0.5 dyinp=0.5 NONSTATionary tbeginp=$date1.000000   \&:" INPUT.swn
sed -i "36 s:.*:\t\tdeltinp=3 HR tendinp=$date2.000000:" INPUT.swn
sed -i "42 s:.*:   BOUndnest3\tWWIII 'ww3.$date3.spc' OPEN:" INPUT.swn
sed -i "62 s:.*:\t\ttbegnst=$date1.000000 deltnst=1 HR:" INPUT.swn
sed -i "71 s:.*:\t\tTM01 WIND XP YP OUTPUT tbegblk=$date1.000000 deltblk=1 HR:" INPUT.swn
sed -i "76 s:.*:\t\ttendc=$date2.000000:" INPUT.swn

if [ ! -f ./restart ]; then
	echo " *** WARNING!!! Hotfile is missing, continuing without Hotfile!"
	sed -i '44 s:^:!:' INPUT.swn
	sed -i "75 s:.*:   COMPute\tNONSTATION tbegc=$date1.000000 deltc=1 HR\t\t    \&:" INPUT.swn
	status=1
else
	stat -c %y restart > time_res.tmp
	stat --printf="%s" restart > size_res.tmp
	sed -i 's:\([0-9]*-[0-9]*-[0-9]*\).*:\1:' time_res.tmp
	ydate=`date -d "$date1 -1 day" +%Y-%m-%d`
	res_date=`sed -n 1p time_res.tmp`
	res_size=`sed -n 1p size_res.tmp`
#	res_date="2016-09-15"
	if [[ "$ydate" == "$res_date" ]] && [[ $res_size -gt 150000000 ]]; then
		echo ' *** The Hotfile seems OK! Using it *** '
		echo ' '
		echo ' '	
		status=2
	else
		echo " *** WARNING!!! The current Hotfile seems broken and therefore is not applicable! ***"
		echo "     Continuing without using Hotfile..."
		rm -fv restart
		sed -i '44 s:^:!:' INPUT.swn
		sed -i "75 s:.*:   COMPute\tNONSTATION tbegc=$date1.000000 deltc=1 HR\t\t    \&:" INPUT.swn
		echo ' '
		echo ' '
		status=3
	fi
fi

swanrun -input INPUT.swn -mpi 8

#while [[ $( printf "%.0f" `mpstat | grep -Po 'all.* \K[^ ]+$'` ) -lt 70 ]]; do
#	echo "Checking available resources..."
#	echo "the CPU load is `mpstat | grep -Po 'all.* \K[^ ]+$'`"
#	echo "Waiting for enough available resources..."
#	echo "..."
#	echo " "
#	sleep 2
#done

rm -fv INPUT.swn
mv -fv Chabahar_NESTout ../Nested
echo 'Done!'
echo ' '
echo ' '

echo " --> Running SWAN Coarse-Grid Model for the next 24 hours..."
cp -fv INPUT.swn.restart INPUT.swn
date2=`date -d "$date1 +1 day" +%Y%m%d`

sed -i "35 s:.*:\t\tdxinp=0.5 dyinp=0.5 NONSTATionary tbeginp=$date1.000000   \&:" INPUT.swn
sed -i "36 s:.*:\t\tdeltinp=3 HR tendinp=$date2.000000:" INPUT.swn
sed -i "42 s:.*:   BOUndnest3\tWWIII 'ww3.$date3.spc' OPEN:" INPUT.swn
sed -i "68 s:.*:\t\ttendc=$date2.000000:" INPUT.swn

case $status in
	1)
	  echo " *** WARNING!!! Hotfile is missing, continuing without Hotfile!"
	  sed -i '44 s:^:!:' INPUT.swn
	  sed -i "67 s:.*:   COMPute\tNONSTATION tbegc=$date1.000000 deltc=1 HR\t\t    \&:" INPUT.swn
	  ;;
	2)
	  echo ' *** The Hotfile seems OK! Using it *** '
	  echo ' '
	  echo ' '
	  ;;
	3)
	  echo " *** WARNING!!! The current Hotfile seems broken and therefore is not applicable! ***"
	  echo "     Continuing without using Hotfile..."
	  sed -i '44 s:^:!:' INPUT.swn
	  sed -i "67 s:.*:   COMPute\tNONSTATION tbegc=$date1.000000 deltc=1 HR\t\t    \&:" INPUT.swn
	  echo ' '
	  echo ' '
	  ;;
esac

swanrun -input INPUT.swn -mpi 8
./hcat.exe restart
rm -fv INPUT.swn
echo 'Done!'
echo ' '
echo ' '

cd  ../Nested

echo " --> Running SWAN Nested-Grid Model for the next 96 hours..."
cp -fv INPUT.swn.original INPUT.swn
#date1=`sed -n 1p ./$dir/temp.txt`
date1=$today
date2=`date -d "$date1 +4 day" +%Y%m%d`

sed -i "35 s:.*:\t\tdxinp=0.5 dyinp=0.5 NONSTATionary tbeginp=$date1.000000   \&:" INPUT.swn
sed -i "36 s:.*:\t\tdeltinp=3 HR tendinp=$date2.000000:" INPUT.swn
sed -i "64 s:.*:\t\tTM01 WIND XP YP OUTPUT tbegblk=$date1.000000 deltblk=1 HR:" INPUT.swn
sed -i "69 s:.*:\t\ttendc=$date2.000000:" INPUT.swn

if [ ! -f ./restart ]; then
	echo " *** WARNING!!! Hotfile is missing, continuing without Hotfile!"
	sed -i '44 s:^:!:' INPUT.swn
	sed -i "68 s:.*:   COMPute\tNONSTATION tbegc=$date1.000000 deltc=1 HR\t\t    \&:" INPUT.swn
	status=1
else
	stat -c %y restart > time_res.tmp
	stat --printf="%s" restart > size_res.tmp
	sed -i 's:\([0-9]*-[0-9]*-[0-9]*\).*:\1:' time_res.tmp
	ydate=`date -d "$date1 -1 day" +%Y-%m-%d`
	res_date=`sed -n 1p time_res.tmp`
	res_size=`sed -n 1p size_res.tmp`
#	res_date="2016-09-15"
	if [[ "$ydate" == "$res_date" ]] && [[ $res_size -gt 2500000 ]]; then
		echo ' *** The Hotfile seems OK! Using it *** '
		echo ' '
		echo ' '	
		status=2
	else
		echo " *** WARNING!!! The current Hotfile seems broken and therefore is not applicable! ***"
		echo "     Continuing without using Hotfile..."
		rm -fv restart
		sed -i '44 s:^:!:' INPUT.swn
		sed -i "68 s:.*:   COMPute\tNONSTATION tbegc=$date1.000000 deltc=1 HR\t\t    \&:" INPUT.swn
		echo ' '
		echo ' '
		status=3
	fi
fi

if [ ! -f ./Chabahar_NESTout ]; then
	echo " *** ERROR!!! Nestout file is missing, SWAN will generate error!"
	echo ' '
	echo ' '
else
	stat -c %y Chabahar_NESTout > time_nes.tmp
	stat --printf="%s" Chabahar_NESTout > size_nes.tmp
	sed -i 's:\([0-9]*-[0-9]*-[0-9]*\).*:\1:' time_nes.tmp
	nes_date=`sed -n 1p time_nes.tmp`
	nes_size=`sed -n 1p size_nes.tmp`
#	nes_date="2016-09-16"
	if [[ "`date -d $date1 +%Y-%m-%d`" == "$nes_date" ]] && [[ $nes_size -gt 100000000 ]]; then
		echo ' *** The Nestout file seems OK! Using it *** '
		sed -i "1 s:.*:SWAN:" Chabahar_NESTout
		sed -i '2,3d' Chabahar_NESTout
		echo ' '
		echo ' '	
	else
		echo " *** ERROR!!! The current Nestout file seems broken and therefore is not applicable! ***"
		echo "     SWAN will generate error!"
		echo ' '
		echo ' '
	fi
fi

swanrun -input INPUT.swn

#while [[ $( printf "%.0f" `mpstat | grep -Po 'all.* \K[^ ]+$'` ) -lt 70 ]]; do
#	echo "Checking available resources..."
#	echo "the CPU load is `mpstat | grep -Po 'all.* \K[^ ]+$'`"
#	echo "Waiting for enough available resources..."
#	echo "..."
#	echo " "
#	sleep 2
#done

rm -fv INPUT.swn
echo 'Done!'
echo ' '
echo ' '

echo " --> Running SWAN Nested-Grid Model for the next 24 hours..."
cp -fv INPUT.swn.restart INPUT.swn
date2=`date -d "$date1 +1 day" +%Y%m%d`

sed -i "35 s:.*:\t\tdxinp=0.5 dyinp=0.5 NONSTATionary tbeginp=$date1.000000   \&:" INPUT.swn
sed -i "36 s:.*:\t\tdeltinp=3 HR tendinp=$date2.000000:" INPUT.swn
sed -i "68 s:.*:\t\ttendc=$date2.000000:" INPUT.swn

case $status in
	1)
	  sed -i '44 s:^:!:' INPUT.swn
	  sed -i "67 s:.*:   COMPute\tNONSTATION tbegc=$date1.000000 deltc=1 HR\t\t    \&:" INPUT.swn
	  ;;
	2)
	  echo ' *** The Hotfile seems OK! Using it *** '
	  echo ' '
	  echo ' '
	  ;;
	3)
	  echo " *** WARNING!!! The current Hotfile seems broken and therefore is not applicable! ***"
	  echo "     Continuing without using Hotfile..."
	  sed -i '44 s:^:!:' INPUT.swn
	  sed -i "67 s:.*:   COMPute\tNONSTATION tbegc=$date1.000000 deltc=1 HR\t\t    \&:" INPUT.swn
	  echo ' '
	  echo ' '
	  ;;
esac

swanrun -input INPUT.swn
rm -fv INPUT.swn
echo 'Done!'
echo ' '
echo ' '

echo " --> Doing Some Housekeeping, Please be Patient..."
rm -f *.tmp
cat INPUT.prt INPUT.erf norm_end > all_run.log 2>/dev/null
rm -f INPUT.prt INPUT.erf norm_end 2>/dev/null
tar -cvjSf ./OUTPUT_Nested.tar.bz2 ./all_run.log OUTPUT Chabahar_NESTout restart
mv -f ./OUTPUT_Nested.tar.bz2 ../../$dir/Indian/
rm -f all_run.log OUTPUT Chabahar_NESTout

cd ../Coarse
rm -f *.*-00* *-00* *.tmp
cat INPUT.prt INPUT.erf norm_end > all_run.log 2>/dev/null
rm -f INPUT.prt INPUT.erf norm_end 2>/dev/null
tar -cvjSf ./OUTPUT_Coarse.tar.bz2 ./all_run.log OUTPUT restart *.spc
mv -f ./OUTPUT_Coarse.tar.bz2 ../../$dir/Indian/
rm -f all_run.log OUTPUT *.spc

echo '/*------------------Done!-----------------*/'
echo ' '
echo ' '

end=`date +%s`
runtime=$((end-start))
echo "******************************"
echo "*   Elapsed Time: $runtime Seconds  *"
echo "******************************"

mv -f ../CRON.log ../../$dir/Indian/SWAN.log
exit 0




# to do list:
# remove line setting nes_date (line:186) for test reasons
# hotfiles and nestout size! Should they be checked?
