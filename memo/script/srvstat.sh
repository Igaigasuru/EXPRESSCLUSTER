#!/ bin/sh
#***********************************************************************
#*                             srvstat.sh                              *
#*                                                                     *
#*  This script checks whether all cluster servers are Online or not.  *
#***********************************************************************

ulimit -s unlimited

clpstat -n | grep "\[on server" | while read line
do
  echo $line | grep "Online"
  if [ $? -ne 0 ]
  then
    exit 1
  fi
done
if [ $? -eq 1 ]
then
  echo "Error! Server status is not normal."
  exit 1
fi

echo "Success! Server status is normal."
exit 0
