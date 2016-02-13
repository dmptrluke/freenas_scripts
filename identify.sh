#!/bin/sh

drives=$(for drive in $(sysctl -n kern.disks); do \
if [ "$(smartctl -i /dev/${drive} | grep "Serial Number" | awk '{print $3}')" ]
then printf ${drive}" "; fi done | awk '{for (i=NF; i!=0 ; i--) print $i }')

echo ""
echo "+========+============================================+=================+"
echo "| Device | GPTID                                      | Serial          |"
echo "+========+============================================+=================+"
for drive in $drives
do
    gptid=`glabel status -s "${drive}p2" | awk '{print $1}'`
    serial=`smartctl -i /dev/${drive} | grep "Serial Number" | awk '{print $3}'`
    printf "| %-6s | %-42s | %-15s |\n" "$drive" "$gptid" "$serial"
    echo "+--------+--------------------------------------------+-----------------+"
done
echo ""