#!/ bin/sh
#***********************************************************************
#*                               grpstat.sh                            *
#*                                                                     *
#*  This script checks whether a target failover group on own server.  *
#*  Please set the target failover grourp name as "grpname".           *
#***********************************************************************

ulimit -s unlimited
grpname=

ownhostname=`hostname`
echo "This is $ownhostname server."

ownsrv=`clpstat -g | grep $ownhostname | awk -F: '{print $1}' | sed "s/ //g" | cut -c 2-`

clpstat -g | grep "${grpname}\[o\]" | grep $ownsrv
if [ $? -eq 1 ] ;
then
  echo "Group $grpname is Not Active on this server."
  exit 1
fi

echo "Group $grpname is Active on this server."
exit 0
