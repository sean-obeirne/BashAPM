#!/bin/bash

# NSSA 220 Project 1: APM Tool
# Sean O'Beirne, Mani Perez, Joshua Sylvester

spawn_processes(){
   # grab NIC ip
   local ip=$(ifconfig ens33 | grep "inet" | head -1 | cut -f 10 -d " ")

   # cleanup old metrics files
   rm APM?_metrics.csv system_metrics.csv

   # spawn procs & create files
   for (( i = 1; i <= $PROCS; i++ ))
   {
       ./project1_executables/APM$i $ip &
      touch 'APM'$i'_metrics.csv'
   }
   touch system_metrics.csv
   ifstat -a -d 1 ens33
}

get_stuff(){
   # out to console FOR DEBUGGING
   echo "$sec seconds"
   for (( i = 1; i <= $PROCS; i++ ))
   {
      ps u -C "APM$i" | grep "APM" | awk '{print $3 " " $4}'
   }
   ifstat | grep "ens33" | awk '{print $6 " " $7}'
   iostat | grep "sda" | awk '{print $4}'
   df -hm / | grep "root" | awk '{print $4}'

   # out to file

   # proc-level metrics
   for (( i = 1; i <= $PROCS; i++ ))
   {
      echo "$sec," >> 'APM'$1'_metrics.csv'
      ps u -C "APM$i" | grep "APM" | awk '{print $3 "," $4 ","}' >> APM$1'_'metrics.csv
   }
   
   # system-level metrics
   echo -n "$sec," >> system_metrics.csv
   ifstat | grep "ens33" | awk '{print $6 "," $7 ","}' >> system_metrics.csv
   iostat | grep "sda" | awk '{print $4 ","}' >>  system_metrics.csv
   df -hm / | grep "root" | awk '{print $4}' >> system_metrics.csv
}

cleanup(){
   killall -r "APM[1-6]"
   killall "ifstat"
}

PROCS=6
f1="APM1_metrics.csv"

trap cleanup EXIT

spawn_processes
f=1
sec=1
sleep 1
while [ $f -eq 1 ];
do
   if ! (( sec % 5 ));
   then
      echo "---------------------"
      get_stuff
      echo "---------------------"
   fi
   sleep 1
   sec=$((sec + 1));
done
