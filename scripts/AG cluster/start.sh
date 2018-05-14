#! /bin/sh
#***********************************************
#*     MSSQL for Linux AG cluster start.sh     *
#***********************************************

#ulimit -s unlimited

export PATH="$PATH:/opt/mssql-tools/bin"

user="SA"
pass="<SA user password>"
rolesrc="/opt/nec/clusterpro/scripts/failover/sqlcommand/role.sql"
isfosrc="/opt/nec/clusterpro/scripts/failover/sqlcommand/is_failover_ready.sql"
fosrc="/opt/nec/clusterpro/scripts/failover/sqlcommand/agFailover.sql"

echo "Start exec."

local_role=`sqlcmd -U ${user} -P ${pass} -i ${rolesrc} | sed -z 's/\n/ /g' | awk -F ' ' '{print $3}'`
if [ $? -ne 0 ];
then
  echo "Error: Failed to execute "sqlcmd" command."
  exit 1
fi  

if [ $local_role = "PRIMARY" ];
then
  echo "Info: This server is already PRIMARY role."
  exit 0
fi

local_isfo=`sqlcmd -U ${user} -P ${pass} -i ${isfosrc} | sed -z 's/\n/ /g' | awk -F ' ' '{print $3}'`
if [ $? -ne 0 ];
then
  echo "Error: Failed to execute "sqlcmd" command."
  exit 1
fi  

if [ $local_isfo -ne 1 ];
then
  echo "Error: This server is not ready for failover."
  exit 1
fi

sqlcmd -U ${user} -P ${pass} -i ${fosrc}
if [ $? -ne 0 ];
then
  echo "Error: Failed to execute failover."
  exit 1
fi

echo "Succeeded to execute failover."
exit 0
