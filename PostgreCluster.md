# How to setup PostgreSQL DB Cluster

## System environment
```bat
RHEL 7.2 (kernel: 3.10.0-327.el7.x86_64)
PostgreSQL 10-10.1
EXPRESSCLUSTER X 3.3 for Linux (3.3.5-1)

## System setup

<<DB Server>>

1. Basic cluster setup
	1. On Primary and Secondary servers  
		1. Install ECX  
		1. Register licenses  
	1. On Primary server  
		1. Create a cluster and a failover group  
			- Group:
				- group  
			- Resource:  
				- fip  
				sd or md  
		1. Start group on Primary server  
1. PostgreSQL installation
	1. On both Servers
		1. Install PostgreSQL on both Servers
			postgresql10-10.1-1PGDG.rhel7.x86_64  
			postgresql10-contrib-10.1-1PGDG.rhel7.x86_64  
			postgresql10-libs-10.1-1PGDG.rhel7.x86_64  
			postgresql10-server-10.1-1PGDG.rhel7.x86_64  
		1. Confirm PosgreSQL user name and ID on both Servers are the same
			```bat
			# id postgres
			```
			If PostgreSQL user is not created, please create on both Servers with a same name and ID.
			```bat
			# useradd -u 26 postgres
			```
	1. On Primary Server (active)
		1. Create directory to store database under sd or md Mount Point (e.g. "/mnt/sdb2") and change its owner to postgres user.
			```bat
			# mkdir -p /mnt/sdb2/pgsql/data
			# chown -R postgres:postgres /mnt/sdb2/pgsql/data
			# chmod 700 /mnt/sdb2/pgsql/data
			```
		1. Create database cluster under the directory as a postgres user.
			```bat
			# su - postgres
			$ /usr/pgsql-10/bin/initdb -D /mnt/sdb2/pgsql/data -E UTF8 --no-locale -W
			```
		1. Edit database config file as you like.
			- /mnt/sdb2/pgsql/data/pg_hba.conf
				For example, allow connection through all IP interfaces with port 5432 (default port).
				```bat
				listen_address = '*'
				port = 5432
				```
			- /mnt/sdb2/pgsql/data/pg_hba.conf
				For example, allow connection from machines which belong to 192.168.10.0/24.
				```bat
				host all all 192.168.10.0/24 md5
				```
		1. Create database (e.g. "db1") as a postgre user after starting DB server.
			```bat
			# su - postgres
			$ /usr/pgsql-10/bin/pg_ctl start -D /mnt/sdb2/pgsql/data -l /dev/null
			$ /usr/pgsql-10/bin/createdb -h localhost -U postgres db1
			```
			After completing to create db1, stop DB server.
			```bat
			$ /usr/pgsql-10/bin/pg_ctl stop -D /mnt/sdb2/pgsql/data -m fast
			```
		1. Failover group from Primary Server to Secondary Server.
	1. On Secondary Server (active)
		1. Start DB server and confirm that you can connect to the database which was created on Primary Server.
			```bat
			# su - postgres
			$ /usr/pgsql-10/bin/pg_ctl start -D /mnt/sdb2/pgsql/data -l /dev/null
			$ /usr/pgsql-10/bin/psql -h localhost -U postgres db1
			```
			After connecting to the database, stop the DB server.
			```bat
			$ /usr/local/pgsql/bin/pg_ctl stop -D /mnt/sdb2/pgsql/data -m fast
			```
1. PostgreSQL cluster setup
	1. Add resources to group
		- exec_postgres
			- start.sh (synchronous):  
				Refer the appendix start.sh.  
			- stop.sh (synchronous):  
				Refer the appendix stop.sh.  
	1. Change resource dependency as the below:  
		- 0  fip  
		1  sd / md  
		2  exec_postgres  
	1. Apply the configuration and confirm cluster behaviour.

## Appendix
Sample script for start.sh:  
```bat
#! /bin/sh
#***************************************
#*              start.sh               *
#***************************************

ulimit -s unlimited

SUUSER="postgres" # PG user name(OS user)
PGINST="/usr/pgsql-10" # PG Install directory
PGDATA="/mnt/sdb2/pgsql/data" # Database directory
PGPORT="5432" # Database Port number

if [ -f ${PGDATA}/postmaster.pid ]
then
        rm -f ${PGDATA}/postmaster.pid
fi
if [ -f /tmp/.s.PGSQL.${PGPORT} ]
then
        rm -f /tmp/.s.PGSQL.${PGPORT}
fi

if [ "$CLP_DISK" = "SUCCESS" ]
then
        su - ${SUUSER} -c "${PGINST}/bin/pg_ctl start -D ${PGDATA} -l /dev/null -o '-i -p ${PGPORT}'"
else
        echo "ERROR_DISK from START"
        exit 1
fi

echo "EXIT"
exit 0
```
Sample script for stop.sh:  
```bat
#! /bin/sh
#***************************************
#*              start.sh               *
#***************************************

ulimit -s unlimited

SUUSER="postgres" # PG user name(OS user)
PGINST="/usr/pgsql-10" # PG Install directory
PGDATA="/mnt/md1/pgsql/data" # Database directory
PGPORT="5432" # Database Port number

if [ "$CLP_DISK" = "SUCCESS" ]
then
        su - ${SUUSER} -c "${PGINST}/bin/pg_ctl stop -D ${PGDATA} -m fast"
else
                echo "ERROR_DISK from START"
                exit 1
fi
echo "EXIT"
exit 0
```
