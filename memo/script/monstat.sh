#!/ bin/sh
#******************************************************************************
#*                                 monstat.sh                                 *
#*                                                                            *
#* This script checks whether there is no Abnormal status monitor resources.  *
#******************************************************************************

ulimit -s unlimited

clpstat -m | grep Monitor | while read line
do
  echo "$line" | grep "Normal\]"
  if [ $? -ne 0 ];
  then
    exit 1
  fi
done
if [ $? -eq 1 ];
then
  echo "Some monitor resource status are Not Normal."
  exit 1
fi

echo "All monitor resources status is Normal."
exit 0
