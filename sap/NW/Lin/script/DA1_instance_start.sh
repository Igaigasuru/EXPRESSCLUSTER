#!/bin/sh
#********************************************************
#*      instance  start.sh       (Version : 3.3-2)      *
#********************************************************

ulimit -s unlimited

#***************************************
# INSTANCE : SAP instance name
# TIMEOUT  : Timeout sec
# DELAY    : Delay sec
#***************************************

#***************************************
INSTANCE="DAA_SMDA98_host1"
#***************************************

TIMEOUT="150"
DELAY="2"

#***************************************

SID=`echo "${INSTANCE}" | cut -d_ -f1`
INAME=`echo "${INSTANCE}" | cut -d_ -f2`
INO=`echo "${INAME}" | sed 's/.*\([0-9][0-9]\)$/\1/'`
SAPUSER=`echo "${SID}adm" | tr "[:upper:]" "[:lower:]"`

if [ -z "${CLP_EVENT}" ]
then
	echo "NO_CLP"
	exit 1
fi

su - ${SAPUSER} -c "sapcontrol -prot NI_HTTP -nr ${INO} -function WaitforServiceStarted ${TIMEOUT} ${DELAY}"
if [ $? -ne 0 ]
then
	echo "sapstartsrv does not start."
	exit 1
fi

su - ${SAPUSER} -c "sapcontrol -prot NI_HTTP -nr ${INO} -function StartWait ${TIMEOUT} ${DELAY}"
if [ $? -ne 0 ]
then
	echo "failed to start instance."
	exit 1
fi

echo "EXIT"
exit 0
