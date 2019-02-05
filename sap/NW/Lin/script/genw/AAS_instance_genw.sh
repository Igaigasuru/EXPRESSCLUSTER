#!/bin/sh
#***********************************************
#* PAS/AAS instance genw.sh  (Version : 4.1-1) *
#***********************************************

ulimit -s unlimited

#***********************************************
# INSTANCE      : PAS/AAS instance name
# CHECK_MONNAME : Monitor resource name for checking shared filesystem
# DIR_PATH      : Directory path of check_monitor_status.sh
#***********************************************

#***********************************************
INSTANCE="NEC_D40_host2"
CHECK_MONNAME="diskw-NFS"
DIR_PATH="/opt/nec/clusterpro/scripts/utility"
#***********************************************

TARGETS="disp+work igswd_mt gwrd icman"

#***********************************************

CONFFILE="/opt/nec/clusterpro/etc/clp_shi_connector.conf"

SID=`echo "${INSTANCE}" | cut -d_ -f1`
INAME=`echo "${INSTANCE}" | cut -d_ -f2`
INO=`echo "${INAME}" | sed 's/.*\([0-9][0-9]\)$/\1/'`
SAPUSER=`echo "${SID}adm" | tr "[:upper:]" "[:lower:]"`

# Check monitor status for shared filesystem
if [ -n "${CHECK_MONNAME}" -a "${CHECK_MONNAME}" != "<DISKW>" ]; then
	if [ ! -e ${DIR_PATH}/check_monitor_status.sh ]; then
		/usr/sbin/clplogcmd -m "${DIR_PATH}/check_monitor_status.sh does not exist." -l warn
		exit 0
	fi
	${DIR_PATH}/check_monitor_status.sh "${CHECK_MONNAME}"
	if [ $? -ne 0 ]; then
		/usr/sbin/clplogcmd -m "Skip monitoring ${INSTANCE} instance due to the monitor resource ${CHECK_MONNAME} is not normal." -l warn
		exit 0
	fi
fi

YELLOW_AS_ERROR=1
if [ -f "${CONFFILE}" ]
then
	. ${CONFFILE}
	if [ "${YELLOW_AS_ERROR}" = "" ]
	then
		YELLOW_AS_ERROR=1
	fi
fi

# Check instance status
for TARGET in ${TARGETS}
do
	LINE=`su - ${SAPUSER} -c "sapcontrol -nr ${INO} -function GetProcessList" | grep "${TARGET}"`
	COLOR=`echo ${LINE} | cut -f3 -d, | sed 's/^[ \t]*//g' | sed 's/,$//g'`
	if [ "${COLOR}" != "GREEN" ]
	then
		if [ "${COLOR}" != "YELLOW" ]
		then
			exit 1
		else
			if [ ${YELLOW_AS_ERROR} -ne 0 ]
			then
				exit 1
			fi
		fi
	fi
done

exit 0
