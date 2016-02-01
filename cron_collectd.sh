#!/bin/bash

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
    sed -i 's/LoadPlugin zfs_arc$//' $conf
    perl -pe 's/\Q+(p[0123456789]+)?(\.eli)?//' $conf
    service collectd restart
    logger -p user.warn -t "collectd" \
         "Added custom configuration to collectd and restarted service."
fi