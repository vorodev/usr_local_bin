#!/bin/sh
# vorodev AT github
# 20120531
# import remote production databases to local development machine

DATABASES="db1 db2"
RUSER="sshuser"
RHOST="www.example.com"
SSHPORT="123456"

echo " "
echo "SSH passwd?"
stty -echo
read sshpass
stty echo
echo "remote DB passwd?"
stty -echo
read rdbpass
stty echo
echo "local DB passwd?"
stty -echo
read ldbpass
stty echo
echo " "

echo "setting failsafe variables ..."
sshpass -p $sshpass ssh -p $SSHPORT -C $RUSER"@"$RHOST mysql -B -A -u root --password=$rdbpass -e "'set global wait_timeout=31536000'"
sshpass -p $sshpass ssh -p $SSHPORT -C $RUSER"@"$RHOST mysql -B -A -u root --password=$rdbpass -e "'set global interactive_timeout=31536000'"
sshpass -p $sshpass ssh -p $SSHPORT -C $RUSER"@"$RHOST mysql -B -A -u root --password=$rdbpass -e "'set global connect_timeout=600'"
sshpass -p $sshpass ssh -p $SSHPORT -C $RUSER"@"$RHOST mysql -B -A -u root --password=$rdbpass -e "'set global max_allowed_packet=1073741824'"


echo "dumping databases..."
mysql -B -A -u root --password=$ldbpass -e 'SET GLOBAL FOREIGN_KEY_CHECKS = 0'
for database in $DATABASES
do
echo "  "$database
sshpass -p $sshpass ssh -p $SSHPORT -C $RUSER"@"$RHOST mysqldump --compact -q --max_allowed_packet=1G --force --skip-lock-tables --lock-tables=false --single-transaction --add-drop-database -u root --password=$rdbpass --databases $database | mysql -u root --password=$ldbpass
sleep 10s
done
mysql -B -A -u root --password=$ldbpass -e 'SET GLOBAL FOREIGN_KEY_CHECKS = 1'
echo "done dumping"

echo "restoring variables ..."
sshpass -p $sshpass ssh -p $SSHPORT -C $RUSER"@"$RHOST mysql -B -A -u root --password=$rdbpass -e "'set global wait_timeout=600'"
sshpass -p $sshpass ssh -p $SSHPORT -C $RUSER"@"$RHOST mysql -B -A -u root --password=$rdbpass -e "'set global interactive_timeout=600'"
sshpass -p $sshpass ssh -p $SSHPORT -C $RUSER"@"$RHOST mysql -B -A -u root --password=$rdbpass -e "'set global max_allowed_packet=2097152'"
sshpass -p $sshpass ssh -p $SSHPORT -C $RUSER"@"$RHOST mysql -B -A -u root --password=$rdbpass -e "'set global connect_timeout=10'"
echo "finished!"
echo " "
