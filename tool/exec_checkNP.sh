#! /bin/sh
#************************************************************************
#*                        exec_checkNP start.sh                         *
#*                                                                      *
#* This script check the server is NP or not by executing ping to all   *
#* other servers HBs and PingNP target.                                 *
#*                                                                      *
#* It is required that only one PingNP Target is set for the cluster    *
#* (Regarding HBs or DiskNP, there is no restriction.)                  *
#************************************************************************

#ulimit -s unlimited

CONF=/opt/nec/clusterpro/etc/clp.conf
pingRetry=1

function checkHB() {
xmllint --xpath "/root" $CONF | grep "server name" | grep -v `hostname` | awk -F\" '{ print $2}' | while read line
do
  count=0
  while :
  do
    ip=`xmllint --xpath "/root/server[@name=\"$line\"]/device[@id=\"$count\"]/info/text()" $CONF`
    if [ $? -ne 0 ]
    then
      return 1
    fi
    echo `date "+%y/%m/%d %H:%M:%S.%3N"`"    Ping $ip."
    ping -c $pingRetry $ip
    if [ $? -eq 0 ]
    then
      echo `date "+%y/%m/%d %H:%M:%S.%3N"`"    Ping succeeded."
      return 0
    fi
    echo `date "+%y/%m/%d %H:%M:%S.%3N"`"    Ping failed."
    count=$[$count+1]
  done
done
}

function checkNP() {
xmllint --xpath "/root/networkpartition" $CONF | grep "pingnp name" | awk -F\" '{ print $2}' | while read line
do
  ip=`xmllint --xpath "/root/networkpartition/pingnp[@name=\"$line\"]" $CONF | grep "<ip>" | sed -e 's/<ip>//g' | sed -e 's/<\/ip>//g' | sed -e 's/ //g'`
  echo `date "+%y/%m/%d %H:%M:%S.%3N"`"    Ping $ip."
  ping -c $pingRetry $ip > /dev/null
  if [ $? -eq 0 ]
  then
    echo `date "+%y/%m/%d %H:%M:%S.%3N"`"    Ping succeeded."
    return 0
  else
    echo `date "+%y/%m/%d %H:%M:%S.%3N"`"    Ping failed."
    return 1
  fi
done
}

echo `date "+%y/%m/%d %H:%M:%S.%3N"`"  Start exec_checkNP."

echo `date "+%y/%m/%d %H:%M:%S.%3N"`"   Checking HeartBeat."
checkHB
if [ $? -eq 0 ]
then
  echo `date "+%y/%m/%d %H:%M:%S.%3N"`"   HeartBeat is valid."
  echo `date "+%y/%m/%d %H:%M:%S.%3N"`"  Finish exec_checkNP."
  exit 0
fi
echo `date "+%y/%m/%d %H:%M:%S.%3N"`"  All HeartBeats are invalid."

echo `date "+%y/%m/%d %H:%M:%S.%3N"`"  Checking PingNP."
checkNP
if [ $? -eq 0 ]
then
  echo `date "+%y/%m/%d %H:%M:%S.%3N"`"   PingNP is valid."
  echo `date "+%y/%m/%d %H:%M:%S.%3N"`"  Finish exec_checkNP."
  exit 0
fi
echo `date "+%y/%m/%d %H:%M:%S.%3N"`"  All PingNPs are invalid."

echo `date "+%y/%m/%d %H:%M:%S.%3N"`"  Error: Exit exec_checkNP."
exit 1
