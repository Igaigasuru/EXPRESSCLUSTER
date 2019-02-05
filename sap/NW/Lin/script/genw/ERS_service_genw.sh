#!/bin/sh
#****************************************************************
#*      service      genw.sh             (Version : 3.3-2)      *
#****************************************************************

ulimit -s unlimited

#***********************************************
# INSTANCE      : SAP instance name
# CHECK_MONNAME : Monitor resource name for checking shared filesystem
# DIR_PATH      : Directory path of check_monitor_status.sh
#***********************************************

#***********************************************
INSTANCE="NEC_ERS20_erssv"
CHECK_MONNAME="diskw-NFS"
DIR_PATH="/opt/nec/clusterpro/scripts/utility"
#***********************************************

SID=`echo "${INSTANCE}" | cut -d_ -f1`
INAME=`echo "${INSTANCE}" | cut -d_ -f2`
HOST=`echo "${INSTANCE}" | cut -d_ -f3`
SAPUSER=`echo "${SID}adm" | tr "[:upper:]" "[:lower:]"`
INO=`echo "${INAME}" | sed 's/.*\([0-9][0-9]\)$/\1/'`
PROFILE="/usr/sap/${SID}/SYS/profile/${INSTANCE}"

# Check monitor status for shared filesystem
if [ -n "${CHECK_MONNAME}" -a "${CHECK_MONNAME}" != "<DISKW>" ]; then
	if [ ! -e ${DIR_PATH}/check_monitor_status.sh ]; then
		/usr/sbin/clplogcmd -m "${DIR_PATH}/check_monitor_status.sh does not exist." -l warn
		exit 0
	fi
	${DIR_PATH}/check_monitor_status.sh "${CHECK_MONNAME}"
	if [ $? -ne 0 ]; then
		/usr/sbin/clplogcmd -m "Skip monitoring ${INSTANCE} service due to the monitor resource ${CHECK_MONNAME} is not normal." -l warn
		exit 0
	fi
fi

# Check service status
RNAME=`su - ${SAPUSER} -c "sapcontrol -nr ${INO} -function ParameterValue INSTANCE_NAME -format script | grep '^0 :' | cut -d' ' -f3"`
if [ $? -ne 0 ] || [ "${RNAME}" != "${INAME}" ]
then
	echo "sapstartsrv of ${INAME} is not alive."
	exit 1
fi

exit 0
