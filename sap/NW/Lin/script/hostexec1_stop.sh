#!/bin/sh
#********************************************************
#*      hostexec  stop.sh        (Version : 3.3-2)      *
#********************************************************

ulimit -s unlimited

SAPHOSTEXEC="/usr/sap/hostctrl/exe/saphostexec"

if [ -z "$CLP_EVENT" ]
then
	echo "NO_CLP"
	exit 1
fi

${SAPHOSTEXEC} -stop

if [ $? -ne 0 ]
then
	echo "failed to stop saphostexec."
	exit 1
fi

echo "EXIT"
exit 0
