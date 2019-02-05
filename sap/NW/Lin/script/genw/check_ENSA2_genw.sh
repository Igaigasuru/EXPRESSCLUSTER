#! /bin/sh
#***************************************************************************
#*      ENSA2 check.sh                              (Version : 4.1-1)      *
#***************************************************************************

ulimit -s unlimited

ASCS_GROUP="ASCS-Group"
ERS_GROUP="ERS-Group"

CLPLOGCMD="/usr/sbin/clplogcmd"

ASCS_NODE=`clpgrp -n ${ASCS_GROUP}`
if [ $? -ne 0 -o "${ASCS_NODE}" = "" ]
then
	${CLPLOGCMD} -m "Failed to get node name where ASCS is running." -l warn
	exit 0
fi

ERS_NODE=`clpgrp -n ${ERS_GROUP}`
if [ $? -ne 0 ]
then
	${CLPLOGCMD} -m "Failed to get node name where ERS is running." -l warn
	exit 0
fi

if [ "${ASCS_NODE}" = "${ERS_NODE}" ]
then
	${CLPLOGCMD} -m "ASCS and ERS are on the same node." -l err
	exit 1
fi

echo "EXIT"
exit 0
