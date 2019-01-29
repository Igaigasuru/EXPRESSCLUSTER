#!/bin/sh
#***************************************************************************
#*      ASCS instance  start.sh                     (Version : 3.3-2)      *
#***************************************************************************

ulimit -s unlimited

#***************************************************************************
# INSTANCE     : ASCS instance name
# DIR_PATH     : Directory path of ascs_post_handler.sh
# SAP_ERS_INO  : Sequence of ERS instance number
# TIMEOUT      : Timeout sec
# DELAY        : Delay sec
# ENABLED      : Enabling(1) or Disabling(0) the ascs_post_handler (ERS launcher)
#***************************************************************************

#***************************************************************************
INSTANCE="ASCS10"
#***************************************************************************

#DIR_PATH="<directory_path_of_ascs_post_handler.sh>"
SAP_ERS_INO="20"
TIMEOUT="300"
DELAY="2"
ENABLED="1"

#***************************************************************************

CLPLOGCMD="/usr/sbin/clplogcmd"

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

export SID
export SAP_ERS_INO

if [ ! -e ${DIR_PATH}/ascs_post_handler.sh ]
then
        ${CLPLOGCMD} -m "${DIR_PATH}/ascs_post_handler.sh does not exist." -l warn
        exit 0
fi

if [ ${ENABLED} = "1" ]
then
	${DIR_PATH}/ascs_post_handler.sh &
else
	${CLPLOGCMD} -m "ascs_post_handler is not launched by setting."
fi

echo "EXIT"
exit 0
