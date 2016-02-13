#!/bin/sh

### Parameters ###
cores=4
drives=$(for drive in $(sysctl -n kern.disks); do \
if [ "$(smartctl -i /dev/${drive} | grep "Serial Number" | awk '{print $3}')" ]
then printf ${drive}" "; fi done | awk '{for (i=NF; i!=0 ; i--) print $i }')

### CPU ###
echo ""
cores=$((cores - 1))
for core in $(seq 0 $cores)
do
    temp="$(sysctl -a | grep "cpu.${core}.temp" | cut -c24-25 | tr -d "\n")"
    printf "CPU %s: %s C\n" "$core" "$temp"
done

### Disks ###
echo ""
for drive in $drives
do
    serial="$(smartctl -i /dev/${drive} | grep "Serial Number" | awk '{print $3}')"
    temp="$(smartctl -A /dev/${drive} | grep "Temperature_Celsius" | awk '{print $10}')"
    printf "%s %-15s: %s C\n" "$drive" "$serial" "$temp"
done
echo ""

### MB Temperature
MBTemp=`ipmitool sensor list all | grep "System Temp" | awk '{print $4}' | awk '{gsub(/\..*$/,"",$1)}1'`
echo "System: $MBTemp" "C"