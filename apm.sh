#!/bin/bash

# NSSA 220 Project 1: APM Tool
# Sean O'Beirne, Mani Perez, Joshua Sylvester

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

get_stuff(){
   for (( i=0; i<7; i++ ))
   {
      ps u -C "APM$i" | grep "APM" | awk '{print $3 " " $4}'
   }
   ifstat | grep "ens33"
   iostat -t 1 | grep "sda"
   df -hm / | tail -1
}

kill_processes(){
   killall -r "APM[1-6]"
   killall "ifstat"
}
trap kill_processes EXIT

spawn_processes
f=1
sec=1
sleep 1
while [ $f -eq 1 ];
do
   if ! (( sec % 5 ));
   then
      echo "---------------------"
      echo "$sec seconds"
      get_stuff
      echo "---------------------"
   fi
   sleep 1
   sec=$((sec + 1));
done
