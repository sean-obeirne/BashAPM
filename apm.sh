#!/bin/bash

# NSSA 220 Project 1: APM Tool
# Sean O'Beirne, Mani Perez, Joshua Sylvester

cpu_and_mem_stats() {
cpu1=$(ps aux | grep "/APM$1" | awk '{print $3;exit;}');
mem1=$(ps aux | grep "/APM$1" | awk '{print $4;exit;}');
echo "CPU Usage for APM$1: $cpu1"
echo "Memory Usage for APM$1: $mem1"
}

rx_and_tx() {
rx=$(ifstat | grep "ens33" | awk '{print $6;exit;}');
tx=$(ifstat | grep "ens33" | awk '{print $8;exit;}');
echo "RX Data rate: ${rx}B/S" 
echo "TX Data rate: ${tx}B/S"
}
./project1_executables/APM1 192.168.28.2 &
./project1_executables/APM2 192.168.28.2 &
./project1_executables/APM3 192.168.28.2 &
./project1_executables/APM4 192.168.28.2 &
./project1_executables/APM5 192.168.28.2 &
./project1_executables/APM6 192.168.28.2 &

j=1
sec=1
sleep 1
while [ $sec -lt 21 ];
do
if ! (( sec % 5 ));
then
echo "---------------------"
echo "$sec seconds"
while [ $j -lt 6 ]
do
cpu_and_mem_stats $j
j=$(($j + 1));
done
echo "---------------------"
fi
if [ $sec -gt 4 ]
then
rx_and_tx
fi
j=1
sleep 1
sec=$((sec + 1));
done

killall -9 APM1
killall -9 APM2
killall -9 APM3
killall -9 APM4
killall -9 APM5
killall -9 APM6


