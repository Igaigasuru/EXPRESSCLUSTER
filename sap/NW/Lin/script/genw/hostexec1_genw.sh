#!/bin/sh
#****************************************************************
#*      hostexec     genw.sh             (Version : 4.1-1)      *
#****************************************************************

ulimit -s unlimited

SAPHOSTEXEC="/usr/sap/hostctrl/exe/saphostexec"

TARGETS="saphostexec sapstartsrv saposcol"

for TARGET in ${TARGETS}
do
	RESULT=`${SAPHOSTEXEC} -status 2>&1 | grep "${TARGET}"`
	STATUS=`echo ${RESULT} | cut -f2 -d" "`
	PID=`echo ${RESULT} | cut -f5 -d" "`
	if [ "${STATUS}" != "running" -o "${PID}" = "0)" ]
	then
		exit 1
	fi
done

exit 0
