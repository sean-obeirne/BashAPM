#!/bin/bash

# NSSA 220 Project 1: APM Tool
# Sean O'Beirne, Mani Perez, Joshua Sylvester

cpu_and_mem_stats() {
   #cpu1=$(ps aux | grep "/APM$1" | awk '{print $3;exit;}');
   #mem1=$(ps aux | grep "/APM$1" | awk '{print $4;exit;}');
   #echo "CPU Usage for APM$1: $cpu1%"
   #echo "Memory Usage for APM$1: $mem1%"
   ps u -C "APM$1" #| tail -1 | sed "s/    / /g" | sed "s/  / /g" | cut -f 3,4 -d ' '
}

rx_and_tx() {
   #rx=$(ifstat | grep "ens33" | awk '{print $6;exit;}');
   #tx=$(ifstat | grep "ens33" | awk '{print $8;exit;}');
   #echo "RX Data rate: ${rx}B/S" 
   #echo "TX Data rate: ${tx}B/S"
   ifstat ens33
}

hard_disk_util(){
   df -hBM / #| sed "s/    / /g" | cut -f 2,3 -d ' '
}

spawn_processes(){
   local ip=$(ifconfig ens33 | grep "inet" | head -1 | cut -f 10 -d " ")
   ./project1_executables/APM1 $ip &
   ./project1_executables/APM2 $ip &
   ./project1_executables/APM3 $ip &
   ./project1_executables/APM4 $ip &
   ./project1_executables/APM5 $ip &
   ./project1_executables/APM6 $ip &
   ifstat -a -d 1 ens33
}

kill_processes(){
   killall -r "APM[1-6]"
   killall "ifstat"
}
trap kill_processes EXIT

spawn_processes
f=1
j=1
sec=1
sleep 1
while [ $f -eq 1 ];
do
   if ! (( sec % 5 ));
   then
      echo "---------------------"
      echo "$sec seconds"
      while [ $j -le 6 ]
      do
         cpu_and_mem_stats $j
         j=$(($j + 1));
      done
      echo "---------------------"
   fi
   if ! (( $sec % 5 ))
   then
      rx_and_tx
      hard_disk_util
   fi
   j=1
   sleep 1
   sec=$((sec + 1));
done
