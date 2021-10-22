#!/bin/bash

# NSSA 220 Project 1: APM Tool
# Sean O'Beirne, Mani Perez, Joshua Sylvester

# Spawn all necessary APM proccesses and create csv files
spawn_processes(){
   # grab NIC ip
   local ip=$(ifconfig ens33 | grep "inet" | head -1 | cut -f 10 -d " ")

   # cleanup old metrics files
   rm -f APM?_metrics.csv system_metrics.csv

   # spawn procs & create files with headers
   for (( i = 1; i <= $PROCS; i++ ))
   {
      ./project1_executables/APM$i $ip &
      echo "seconds,%CPU,%memory" > 'APM'$i'_metrics.csv'
   }
   echo "seconds,RX data rate,TX data rate,disk writes,available disk capacity" > system_metrics.csv

   # begin ifstat
   ifstat -d 1 ens33
}

# Grabs Process Metrics
proc_metrics(){
   for (( i = 1; i <= $PROCS; i++ )){
      echo -n "$sec," >> 'APM'$i'_metrics.csv'
      ps u -C "APM$i" | grep "APM" | awk '{printf $3 "," $4 "\n"}' >> APM$i'_'metrics.csv
   }
}

# Grabs System Metrics
sys_metrics(){
   echo -n "$sec," >> system_metrics.csv
   ifstat 2> /dev/null | grep "ens33" | sed 's/K//g' | awk '{printf $6 "," $7 ","}' >> system_metrics.csv
   iostat | grep "sda" | awk '{printf $4 ","}' >>  system_metrics.csv
   df -hm / | grep "root" | awk '{printf $4 "\n"}' >> system_metrics.csv
}

# Trap function
# Kill all spawned processes and ifstat, discontinue running loop
cleanup(){
   killall -r "APM[1-6]"
   killall "ifstat"
   cont=0
}
trap cleanup EXIT

PROCS=6  # constant number of APM processes to spawn

spawn_processes

cont=1   # we execute infinitely until cont is not 1
sec=5    # running number of seconds we have been running
sleep 5

# main execution loop
while [ $cont -eq 1 ]
do
   proc_metrics
   sys_metrics
   # optionally define runtime here
   if [ $# -eq 1 ]
   then
      # check if we have executed long enough
      if [ $sec -ge $1 ]
      then
         cleanup
         cont=0
      fi
   fi
   sleep 5
   sec=$((sec + 5))
done
