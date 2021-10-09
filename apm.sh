#!/bin/bash

# NSSA 220 Project 1: APM Tool
# Sean O'Beirne, Mani Perez, Joshua Sylvester

cpu_and_mem_stats() {
cpu1=$(ps aux | grep '/APM$1' | cut -f 7 -d " " | tail -1);
mem1=$(ps aux | grep '/APM$1' | cut -f 9 -d " " | tail -1);
echo "CPU Usage for APM$1: $cpu1%"
echo "Memory Usage for APM$1: $mem1%"
}

./project1_executables/APM1 192.168.28.2 &
./project1_executables/APM2 192.168.28.2 &
./project1_executables/APM3 192.168.28.2 &
./project1_executables/APM4 192.168.28.2 &
./project1_executables/APM5 192.168.28.2 &
./project1_executables/APM6 192.168.28.2 &

i=12
j=1
while [ $i -gt 0 ];
do
while [ $j -lt 6 ];
do
cpu_and_mem_stats $j
j=$((j + 1));
done 
j=1
sleep 5
i=$((i - 1));
done

killall -9 APM1
killall -9 APM2
killall -9 APM3
killall -9 APM4
killall -9 APM5
killall -9 APM6


