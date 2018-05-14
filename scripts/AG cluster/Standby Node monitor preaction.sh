#! /bin/sh
#************************************************************************
#*     MSSQL for Linux AG cluster Standby Node monitor preaction.sh     *
#************************************************************************

export PATH="$PATH:/opt/mssql-tools/bin"

user="SA"
pass="<SA user password>"
sqlcommand="/opt/nec/clusterpro/scripts/failover/sqlcommand/setSecondary.sql"

echo "Start preaction."
echo "Change role to Secondary."

sqlcmd -U ${user} -P ${pass} -i ${sqlcommand} | sed -z 's/\n/ /g' | awk -F ' ' '{print $3}'

if [ $? -ne 0 ];
then
  echo "Error: Failed to change role to Secondary."
  exit 1
fi

echo "Succeeded to change role to Secondary."

exit 0
