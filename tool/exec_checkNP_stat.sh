#! /bin/sh
#***************************************
#*              start.sh               *
#***************************************

#ulimit -s unlimited

ownnode=`clpstat -n | grep \`hostname\` | awk '{print $1}' | cut -c 2-`


echo `date "+%y/%m/%d %H:%M:%S.%3N"`"  Start."

echo `date "+%y/%m/%d %H:%M:%S.%3N"`"  Checking HBs."
clpstat -n | grep "on server" | grep -v $ownnode | grep -v "Offline"
if [ $? -eq 0 ]
then
echo `date "+%y/%m/%d %H:%M:%S.%3N"`"  HB is valid."
echo `date "+%y/%m/%d %H:%M:%S.%3N"`"  Finish."
exit 0
fi
echo `date "+%y/%m/%d %H:%M:%S.%3N"`"  HB is invalid."

# Check NP status
echo `date "+%y/%m/%d %H:%M:%S.%3N"`"  Checking NPs."
clpstat -p | grep "$ownnode" | grep -v "on server" | grep -v "\*" | grep o

if [ $? -eq 0 ]
then
echo `date "+%y/%m/%d %H:%M:%S.%3N"`"  PingNP is valid."
echo `date "+%y/%m/%d %H:%M:%S.%3N"`"  Finish."
exit 0
fi

echo `date "+%y/%m/%d %H:%M:%S.%3N"`"  ERRPR. All HBs and PingNPs are invalid."
echo `date "+%y/%m/%d %H:%M:%S.%3N"`"  Exit."
exit 1
