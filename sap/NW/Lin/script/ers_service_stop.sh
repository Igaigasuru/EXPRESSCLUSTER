#!/bin/sh
#********************************************************
#*      service    stop.sh       (Version : 4.1-1)      *
#********************************************************

ulimit -s unlimited

#***************************************
# INSTANCE : SAP instance name
# INSTANCE_RESOURCE_NAME : CLUSTER instance resource name
# TIMEOUT  : Timeout sec
# DELAY    : Delay sec
# INSTANCE_STOPPED : Return value of sapcontrol when SAP instance is stopped
#***************************************

#***************************************
INSTANCE="NEC_ERS20_erssv"
INSTANCE_RESOURCE_NAME="exec-ERS-SAP-instance_NEC_20"
SERVICE_REGISTRATION=1
#***************************************

TIMEOUT="300"
DELAY="10"
INSTANCE_STOPPED="4"

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

if [ "${CLP_FACTOR}" != "RESOURCERESTART" ]
then
	((MAX_COUNT=${TIMEOUT}/${DELAY}))
	count=0
	while [ ${count} -le ${MAX_COUNT} ]
	do
		sleep ${DELAY}
		su - ${SAPUSER} -c "sapcontrol -nr ${INO} -function GetProcessList"
		if [ $? -eq ${INSTANCE_STOPPED} ]
		then
			break
		fi
		((count=${count}+1))
	done
fi

su - ${SAPUSER} -c "sapcontrol -prot NI_HTTP -nr ${INO} -function StopService"
if [ $? -ne 0 ]
then
	echo "failed to StopService"
	exit 1
fi

service_stopped=0
((MAX_COUNT=${TIMEOUT}/${DELAY}))
count=0
while [ ${count} -le ${MAX_COUNT} ]
do
	RNAME=`su - ${SAPUSER} -c "sapcontrol -nr ${INO} -function ParameterValue INSTANCE_NAME -format script | grep '^0 :' | cut -d' ' -f3"`
	if [ $? -ne 0 -o "${RNAME}" != "${INAME}" ]
	then
		service_stopped=1
		break
	fi
	((count=${count}+1))
	sleep ${DELAY}
done
if [ ${service_stopped} -eq 0 ]
then
	echo "failed to waiting for service to stop"
	exit1
fi

if [ "${SERVICE_REGISTRATION}" != "0" ]
then
        env LD_LIBRARY_PATH=/usr/sap/${SID}/${INAME}/exe \
            /usr/sap/${SID}/${INAME}/exe/sapstartsrv pf=${PROFILE} -unreg
        if [ $? -ne 0 ]
        then
	        echo "failed to unregister"
	        exit 1
        fi
fi

echo "EXIT"
exit 0
