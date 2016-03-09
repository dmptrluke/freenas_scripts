#!/bin/bash
# cron_cryptoaudit.sh
# Designed to check md5 CRC's of honeypot files located throughout the filesystem.

PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/usr/local/sbin:/usr/local/bin:/root/bin:/usr/local/fusion-io

locations=("/mnt/Tank/Shared/Audit")

for i in "${locations[@]}"
do
 cd "$i"
 DIFF_LOG_FILE="/tmp/crypto_diff.log"
 if ! md5 * | diff /mnt/Tank/custom/cryptoaudit/hashes_crypto.chk - > $DIFF_LOG_FILE
 then

  # Header Stuff
  NET_LOG_FILE="/tmp/crypto_net.log"
  MAIL_FILE="/tmp/crypto_alert.mail"


  #netstat -antu | awk '$5 ~ /[0-9]:/{split($5, a, ":"); ips[a[1]]++} END {for (ip in ips) print ips[ip], ip | "/opt/bin/sort -k1 -nr"}' | grep 192.168 >> $NET_LOG_FILE

  # Mail Variables
  MAIL_TO="root"
  MAIL_HEADER_SUBJECT="CryptoLocker Honeypot Triggered on Nyx"
  MAIL="sendmail"

  # Build Mail
  {
    echo "SUBJECT: $MAIL_HEADER_SUBJECT"
    echo ""
    echo "An anti-cryptolocker honeypot on the server Nyx has been triggered."
    echo ""
    echo "The following location has been tampered with:"
          echo "$i"
    echo ""
    echo "Details of modified files:"
    #cat $TMP_LOG_FILE
  } > $MAIL_FILE

  # Send Mail
  $MAIL $MAIL_TO < $MAIL_FILE

  # Remove Temporary Files
  rm -rf $MAIL_FILE $NET_LOG_FILE $DIFF_LOG_FILE
 fi
done