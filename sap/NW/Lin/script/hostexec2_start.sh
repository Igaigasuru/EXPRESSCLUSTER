#!/bin/sh
#********************************************************
#*      hostexec  start.sh       (Version : 4.1-1)      *
#********************************************************

ulimit -s unlimited

export LANG=C

SAPHOSTEXEC="/usr/sap/hostctrl/exe/saphostexec"
PROFILE="/usr/sap/hostctrl/exe/host_profile"

if [ -z "$CLP_EVENT" ]
then
	echo "NO_CLP"
	exit 1
fi

for target in saposcol sapstartsrv
do
	PROCESS=`ps -ef | grep "[/]usr/sap/hostctrl/exe/${target}" | grep "/usr/sap/hostctrl/exe/host_profile"`
	if [ "${PROCESS}" != "" ]
	then
		PID=`echo ${PROCESS} | cut -f2 -d" "`
		kill -9 ${PID}
	fi
done

${SAPHOSTEXEC} pf=${PROFILE}

if [ $? -ne 0 ]
then
	echo "failed to start saphostexec."
	exit 1
fi

echo "EXIT"
exit 0
