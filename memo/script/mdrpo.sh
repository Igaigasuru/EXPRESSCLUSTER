#!/ bin/sh
#***************************************************
#*                     mdrpo.sh                    *
#*                                                 *
#*  This script checks RPO.                        *
#*  Please set md or hd resource name as rscname.  *
#***************************************************

ulimit -s unlimited
rscname=

mdstat=`clpmdstat -m $rscname`

#if [ $? -ne 0 ]
#then
#  echo "Error! Failed to get $rscname status."
#  exit 1
#fi

mdstat1=`echo "$mdstat" | grep "Mirror Color" | awk -F' ' '{print $3}'`
mdstat2=`echo "$mdstat" | grep "Mirror Color" | awk -F' ' '{print $4}'`

if [ $mdstat1 = "YELLOW" ]
then
  echo "--------------------"
  echo "RPO: --"
  echo "\"$rscname\" is under Mirror Recovery. Please wait until Mirror Recovery is completed."
  echo "--------------------"
  exit 1
fi

if [ $mdstat1 != "GREEN" ]
then
  echo "--------------------"
  echo "RPO: --"
  echo "Please activate \"$rscname\" on Production Server."
  echo "--------------------"
  exit 1
fi

if [ $mdstat2 = "GREEN" ]
then
  rpo=`date +"%y/%m/%d %H:%M:%S"`
  echo "--------------------"
  echo "RPO: $rpo (synchronized)"
  echo "No data will be lost."
  echo "--------------------"
  exit 0
fi

if [ $mdstat2 = "RED" ]
then
  lastupdate_date=`echo "$mdstat" | grep "Lastupdate" | awk -F' ' '{print $3}'`
  lastupdate_time=`echo "$mdstat" | grep "Lastupdate" | awk -F' ' '{print $4}'`
  break_date=`echo "$mdstat" | grep "Break" | awk -F' ' '{print $3}'`
  break_time=`echo "$mdstat" | grep "Break" | awk -F' ' '{print $4}'`
  lastupdate="$lastupdate_date $lastupdate_time"
  break="$break_date $break_time"
  if [ "$lastupdate" = "$break" ]
  then
    echo "--------------------"
    echo "RPO: $break"
    echo "Mirroring is disconnected but no data will be lost."
    echo "--------------------"
    exit 0
  fi
  echo "--------------------"
  echo "RPO: $break"
  echo "Update between $break(RPO) - $lastupdate will be lost:"
  echo "--------------------"
  exit 0
fi

echo "--------------------"
echo "RPO: --"
echo "DR server status is unknown."
echo "--------------------"
exit 1
