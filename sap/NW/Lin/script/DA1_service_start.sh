#!/bin/sh
#********************************************************
#*      service   start.sh       (Version : 4.1-1)      *
#********************************************************

ulimit -s unlimited

#***************************************
# INSTANCE : SAP instance name
# TIMEOUT  : Timeout sec
# DELAY    : Delay sec
#***************************************

#***************************************
INSTANCE="DAA_SMDA98_host1"
SERVICE_REGISTRATION=1
#***************************************

TIMEOUT="300"
DELAY="2"

#***************************************

SID=`echo "${INSTANCE}" | cut -d_ -f1`
INAME=`echo "${INSTANCE}" | cut -d_ -f2`
HOST=`echo "${INSTANCE}" | cut -d_ -f3`
SAPUSER=`echo "${SID}adm" | tr "[:upper:]" "[:lower:]"`
INO=`echo "${INAME}" | sed 's/.*\([0-9][0-9]\)$/\1/'`
PROFILE="/usr/sap/${SID}/SYS/profile/${INSTANCE}"

if [ -z "${CLP_EVENT}" ]
then
        echo "NO_CLP"
        exit 1
fi

if [ "${SERVICE_REGISTRATION}" != "0" ]
then
        env LD_LIBRARY_PATH=/usr/sap/${SID}/${INAME}/exe \
            /usr/sap/${SID}/${INAME}/exe/sapstartsrv pf=${PROFILE} -reg
        if [ $? -ne 0 ]
        then
                echo "failed to register"
                exit 1
        fi
fi

su - ${SAPUSER} -c "sapcontrol -prot NI_HTTP -nr ${INO} -function StartService ${SID}"
if [ $? -ne 0 ]
then
        echo "failed to start sapstartsrv."
        exit 1
fi

su - ${SAPUSER} -c "sapcontrol -prot NI_HTTP -nr ${INO} -function WaitforServiceStarted ${TIMEOUT} ${DELAY}"
if [ $? -ne 0 ]
then
        echo "failed to start sapstartsrv."
        exit 1
fi

echo "EXIT"
exit 0
