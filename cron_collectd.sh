#!/bin/bash

# WARNING
# This script is designed for my specific use case.
# There is a 99% chance you DO NOT want to run this on your server.
# It won't do anything bad, but it won't be very useful.

# Collectd config file
conf=/etc/local/collectd.conf

# Fail if I'm not running as root
if (( EUID ))
then
    echo "ERROR: Must be run as root. Exiting." >&2
    exit 1
fi

# Check to see if the line is in the config file
if grep -q Include $conf
then
    : All good, exit quietly.
else
    : Augment collectd config with custom things
	echo "Interval 30
$(cat $conf)" > $conf
    echo 'Include "/root/custom/collectd/*.conf"' >> $conf
    sed -i '' 's/LoadPlugin zfs_arc$//' $conf
    perl -p -i'.bak' -e 's/\Q+(p[0123456789]+)?(\.eli)?//' $conf
    service collectd restart
    logger -p user.warn -t "collectd" \
         "Added custom configuration to collectd and restarted service."
fi