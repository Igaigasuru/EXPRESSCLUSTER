#!/ bin/sh
#******************************************************
#*                       move.sh                      *
#*  This script switchover/switcback failover group.  *
#*  Set fiover group name as grpname.                 *
#******************************************************

ulimit -s unlimited
grpname=

clpgrp -m $grpname
if [ $? -eq 1 ]
then
  echo "Error! Failed to move failover group."
  exit 1
fi

echo "Success! Failover group is moved."
exit 0
