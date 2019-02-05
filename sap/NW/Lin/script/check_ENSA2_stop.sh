#! /bin/sh
#***************************************
#*               stop.sh               *
#***************************************

#ulimit -s unlimited

if [ "$CLP_EVENT" = "START" ]
then
	if [ "$CLP_DISK" = "SUCCESS" ]
	then
		echo "NORMAL1"
		if [ "$CLP_SERVER" = "HOME" ]
		then
			echo "NORMAL2"
		else
			echo "ON_OTHER1"
		fi
	else
		echo "ERROR_DISK from START"
		exit 1
	fi
elif [ "$CLP_EVENT" = "FAILOVER" ]
then
	if [ "$CLP_DISK" = "SUCCESS" ]
	then
		echo "FAILOVER1"
		if [ "$CLP_SERVER" = "HOME" ]
		then
			echo "FAILOVER2"
		else
			echo "ON_OTHER2"
		fi
	else
		echo "ERROR_DISK from FAILOVER"
		exit 1
	fi
else
	echo "NO_CLP"
	exit 1
fi
echo "EXIT"
exit 0
