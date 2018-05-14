#! /bin/sh
#************************************************************
#*     MSSQL for AG cluster Active Node monitor genw.sh     *
#************************************************************

ulimit -s unlimited
export PATH="$PATH:/opt/mssql-tools/bin"

user="SA"
pass="<SA user password>"
rscname="exec"
sqlcommand="/opt/nec/clusterpro/scripts/failover/sqlcommand/role.sql"

echo "Start Active Node monitoring."

localrole=`sqlcmd -U ${user} -P ${pass} -i ${sqlcommand} | sed -z 's/\n/ /g' | awk -F ' ' '{print $3}'`
if [ $? -ne 0 ];
then
  echo "Error: Failed to execute "sqlcmd" command."
  exit 1
fi

if [ $localrole != "PRIMARY" ];
  then
  echo "Error: Availability Group is not PRIMARY role on Active Server."
  exit 1
fi

echo "Succeeded to monitoring."

exit 0
