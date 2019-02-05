#!/bin/sh
#***************************************************************************
#*      ERS instance  start.sh                      (Version : 4.1-1)      *
#***************************************************************************

ulimit -s unlimited

#***************************************************************************
# INSTANCE        : ERS instance name
# DIR_PATH        : Directory path of exclusive_control.sh 
# SAP_ERS_INO     : Sequence of ERS instance number
# EXCLUSIVE_GROUP : Failover group for exclusive activation
# TIMEOUT         : Timeout sec
# DELAY           : Delay sec
#***************************************************************************

#***************************************************************************
INSTANCE="NEC_ERS20_erssv"
#***************************************************************************

DIR_PATH="<directory_path_of_exclusive_control.sh>"
SAP_ERS_INO="20 21"
EXCLUSIVE_GROUP="Exclusive-Group"
TIMEOUT="300"
DELAY="2"

#***************************************************************************

CLPLOGCMD="/usr/sbin/clplogcmd"

CONFFILE="/opt/nec/clusterpro/etc/clp_shi_connector.conf"

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

if [ -f "${CONFFILE}" ]
then
	. ${CONFFILE}
	if [ "${ENSA_VERSION}" != "" -a "${ENSA_VERSION}" != "1" ]
	then
		${CLPLOGCMD} -m "exclusive_control is not launched by setting."
		exit 0
	fi
fi

export SID
export SAP_ERS_INO
export EXCLUSIVE_GROUP

if [ ! -e ${DIR_PATH}/exclusive_control.sh ]
then
	${CLPLOGCMD} -m "${DIR_PATH}/exclusive_control.sh does not exist." -l warn
	exit 0
fi

echo "exclusive_control.sh start"
${DIR_PATH}/exclusive_control.sh start
if [ $? -ne 0 ]
then
	${CLPLOGCMD} -m "exclusive_control.sh failed." -l err
	# Exit 0 because sapcontrol command succeeded.
fi

echo "EXIT"
exit 0
