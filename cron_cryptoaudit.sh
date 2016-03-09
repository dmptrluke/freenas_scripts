#!/bin/bash
# cron_cryptoaudit.sh
# Designed to check md5 CRC's of honeypot files located throughout the filesystem.

PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/usr/local/sbin:/usr/local/bin:/root/bin:/usr/local/fusion-io

locations=("/mnt/Tank/Shared/Audit")

for i in "${locations[@]}"
do
 cd "$i"
 if ! md5 * | diff /mnt/Tank/custom/cryptoaudit/hashes_crypto.chk -
 then

  # Header Stuff
  #TMP_LOG_FILE="/tmp/cryptoaudit.log"

  #netstat -antu | awk '$5 ~ /[0-9]:/{split($5, a, ":"); ips[a[1]]++} END {for (ip in ips) print ips[ip], ip | "/opt/bin/sort -k1 -nr"}' | grep 192.168 >> $TMP_LOG_FILE

  # Mail Variables
  MAIL_FILE="/tmp/crypto_alert.mail"
  MAIL_TO="root"
  MAIL_HEADER_SUBJECT="CRYPTOLOCKER ALERT - LOCATION"
  MAIL="sendmail"

  # Build Mail
  {
          echo "SUBJECT: $MAIL_HEADER_SUBJECT"
          echo ""
          echo "CryptoLocker has compromised the filesystem on the nyx file server."
    echo ""
    echo "Take steps immediately or extreme data loss may occur!"
    echo ""
    echo "The following location has been infected:"
          echo "$i"
    echo ""
    echo "IP Connection information below:"
    #cat $TMP_LOG_FILE
  } > $MAIL_FILE

  # Send Mail
  $MAIL $MAIL_TO < $MAIL_FILE

  # Remove Temporary Files
  rm -rf $MAIL_FILE $TMP_LOG_FILE
 fi
done