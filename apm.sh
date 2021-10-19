#!/bin/bash

# NSSA 220 Project 1: APM Tool
# Sean O'Beirne, Mani Perez, Joshua Sylvester

spawn_processes(){
   local ip=$(ifconfig ens33 | grep "inet" | head -1 | cut -f 10 -d " ")
   for (( i = 0; i < $PROCS; i++ ))
   {
       ./project1_executables/APM$i $ip &
      touch 'APM'$i'_metrics.csv'
   }
   touch system_metrics.csv
   ifstat -a -d 1 ens33
}

get_stuff(){
    echo "$sec seconds"
   for (( i = 0; i < $PROCS; i++ ))
   {
      ps u -C "APM$i" | grep "APM" | awk '{print $3 " " $4}'
   }
   ifstat | grep "ens33" | awk '{print $6 " " $7}'
   iostat | grep "sda" | awk '{print $4}'
   df -hm / | grep "root" | awk '{print $4}'
}

kill_processes(){
   killall -r "APM[1-6]"
   killall "ifstat"
}
trap kill_processes EXIT

PROCS=7

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
