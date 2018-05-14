#! /bin/sh
#**********************************************
#*     MSSQL for Linux AG cluster stop.sh     *
#**********************************************

#ulimit -s unlimited

export PATH="$PATH:/opt/mssql-tools/bin"

user="SA"
pass="<SA user password>"
setsecsrc="/opt/nec/clusterpro/scripts/failover/sqlcommand/setSecondary.sql"

echo "Stop exec."

systemctl status mssq-server
if [ $? -ne 0 ];
then
  echo "Info: mssql-server service is not running."
  exit 0
fi

sqlcmd -U ${user} -P ${pass} -i ${setsecsrc}
if [ $? -ne 0 ];
then
  echo "Error: Failed to stop Availability group."
  exit 1
fi

echo "Succeeded to stop."
exit 0
