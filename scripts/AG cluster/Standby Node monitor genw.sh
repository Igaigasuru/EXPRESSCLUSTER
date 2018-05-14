#! /bin/sh
#***********************************************
#*                   genw.sh                   *
#***********************************************

ulimit -s unlimited
export PATH="$PATH:/opt/mssql-tools/bin"

user="SA"
pass="<SA user password>"
rscname="exec"
sqlcommand="/opt/nec/clusterpro/scripts/failover/sqlcommand/role.sql"

echo "Start Standby Node monitoring."

rscstatus=`clpstat | grep ${rscname} | sed 's/ //g' | awk -F ':' '{print $2}'`
if [ $? -ne 0 ];
then 
  echo "Warn: Failed to execute "clp" command."
  exit 0
fi

local_rscstatus=`clpstat --local | grep ${rscname} | sed 's/ //g' | awk -F ':' '{print $2}'`
if [ $? -ne 0 ];
then 
  echo "Warn: Failed to execute "sqlcmd" command."
  exit 0
fi

local_role=`sqlcmd -U ${user} -P ${pass} -i ${sqlcommand} | sed -z 's/\n/ /g' | awk -F ' ' '{print $3}'`
if [ $? -ne 0 ];
then 
  echo "Warn: Failed to execute "sqlcmd" command."
  exit 0
fi

if [ $rscstatus = "Online" ];
then
  if [ $local_rscstatus != "Online" ];
  then
    if [ $local_role = "PRIMARY" ];
    then
      echo "Error: Availability Group is not SECONDARY role on Standby Server."
      exit 1
    fi
  fi
fi

echo "Succeeded to monitoring."

exit 0
