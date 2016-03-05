#!/bin/sh

# store the start timestamp
timestamp=$(date +%s)

drives=$(for drive in $(sysctl -n kern.disks); do \
if [ "$(smartctl -i /dev/${drive} | grep "Serial Number" | awk '{print $3}')" ]
then printf ${drive}" "; fi done | awk '{for (i=NF; i!=0 ; i--) print $i }')


for drive in $drives
do
    temp="$(smartctl -A /dev/${drive} | grep -E "Temperature_Celsius|Airflow_Temperature_Cel" | awk '{print $10}')"
    curl -i -u monitor:43nu889Q3ypeuRJh6qT4 -XPOST 'http://monitor.local:8086/write?db=monitor&precision=s' --data-binary "system,host=nyx,type=temperature,sensor=$drive value=$temp $timestamp"
done
