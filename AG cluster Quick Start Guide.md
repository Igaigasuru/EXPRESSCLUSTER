# AG cluster Quick Start Guide
## About This Guide
This guide provides how to integrate MSSQL Server for Linux Availability Group (AG) with EXPRESSCLUSTER X and create AG cluster.

The guide assumes its readers to have EXPRESSCLUSTER X basic knowledge and setup skills.

## System Overiew
### System Requirement
- 3 servers are required for AG cluster.
- 1 Ping NP target is required for AG cluster.
- All the servers and Ping NP target are required to be communicatable with each other with IP address.
- MSSQL Server for Linux and EXPRESSCLUSTER X are required to be installed on all servers.

### System Environment
- Server spec  
	```bat
	Mem: 4GB
	CPU Core: 2 for 1 Socket
	Disk: 20GB
	OS: Cent 7.4 (3.10.0-693.21.1.el7.x86_64)
	```
- Software versions  
	```bat
	MSSQL for Linux 2017
	EXPRESSCLUSTER X 3.3.5-1
	```

## Cluster Overview
### Cluster Configuration
- Cluster Properties
	- NP Resolution:
		- Add 1 Ping NP  
			Action at NP occurrence: Stop the cluster service and shutdown OS
- Failover Group★
	- Resurces  
		- fip:  
			Used to connect AG database from Client.
		- exec:  
			Used to manage AG. Please refer "Appendix" for sample scripts.
	- Monitor Resources
		- genw-ActiveNode:  
			Used to monitor Active Server AG role. Please refer "Appendix" for sample scripts.
		- genw-SatndbyNode:  
			Used to monitor Standby Server AG role. Please refer "Appendix" for sample scripts.
		- psw:  
			Used to moitor SQL Server service status.

### Assumptions
- For an access from client to PRIMARY replica, fip is used.
- AG replica on all servers should be operated by EXPRESSCLUSTER.

### Behavior
- When failover group is activated on a server, role of the server replica becomes PRIMARY.  
- When failover group is de-activated on a server, role of the server replica becomes SECONDARY.  
- When failover group is failed over, role of the source server replica becomes SECONDARY and role of the target server replica becomes PRIMARY.  

### Monitoring
- Active node role monitoring:  
	If replica role on Active server is demoted from PRIMARY to SECONDARY by other than EXPRESSCLUSTER operations, it is detected as an error and failover will occur.
- Standby node monitorng:  
	If replica role on Standby server role is promoted from SECONDARY to PRIMARY by other than EXPRESSCLUSTER operations, it is detected as an error and EXPRESSCLUSTER will demote it to SECONDARY.
- Active node service monitoring:  
	If mssql-server service on Active server is stopped by other than EXPRESSCLUSTER operations, it is detected as an error and failover will occur.

## System Setup
### Download and install MSSQL Server
#### On all servers
1. Download repository for SQL Server.  
	```bat
	# sudo curl -o /etc/yum.repos.d/mssql-server.repo https://packages.microsoft.com/config/rhel/7/mssql-server-2017.repo
	```
2. Install SQL Server.  
	```bat
	# yum install -y mssql-server
	```
3. Choose SQL Server edition and set password for SA account. (For our evalation, we choose "2) Developer".)  
	```bat
	# /opt/mssql/bin/mssql-conf setup
	```
4. Confirm tha SQL Server is running.  
	```bat
	# systemctl status mssql-server
	```
5. Open port for SQL Server. (Default port number: 1433.)  
	```bat
	# sudo firewall-cmd --zone=public --add-port=1433/tcp --permanent
	# sudo firewall-cmd --reload
	```
6. Download repository for SQL Server command-line tools.  
	```bat
	# curl -o /etc/yum.repos.d/msprod.repo https://packages.microsoft.com/config/rhel/7/prod.repo
	```
7. If you have installed previous version of the tools, remove it. Then install new one.  
	```bat
	# yum remove unixODBC-utf16 unixODBC-utf16-devel
	# yum install -y mssql-tools unixODBC-devel
	```
8. Set PATH environment variable.  
	```bat
	# echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
	# echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
	# source ~/.bashrc
	```
9. Confirm that SQL Server instance is accessible with "sqlcmd" command.  
	```bat
	# sqlcmd -S localhost -U SA -P '<YourPassword>'
	```

Reference:
https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-red-hat

### Cofigure AG
#### On all servers
1. Edit "/etc/hostname" and define all servers hostname and IP addresses for Name Resolution.  
	```bat
	# sudo vi /etc/hstname
	```
2. Enable AlwaysOn availability groups on each server and restart mssql-server.  
	```bat
	# /opt/mssql/bin/mssql-conf set hadr.hadrenabled  1
	# systemctl restart mssql-server
	```
3. Create user for database mirroring endpoint.  
	```bat
	# sqlcmd -U SA -P <SA password>
	> CREATE LOGIN dbm_login WITH PASSWORD = '<dbm_login password>';
	> CREATE USER dbm_user FOR LOGIN dbm_login;
	> go
	> exit
	```
#### On a primary server
4. Create a certificate and copy certification files to secondary servers.  
	```bat
	# sqlcmd -U SA -P <SA password>
	> CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<Master_Key_Password>';
	> CREATE CERTIFICATE dbm_certificate WITH SUBJECT = 'dbm';
	> BACKUP CERTIFICATE dbm_certificate
	>   TO FILE = '/var/opt/mssql/data/dbm_certificate.cer'
	>   WITH PRIVATE KEY (
	>           FILE = '/var/opt/mssql/data/dbm_certificate.pvk',
	>           ENCRYPTION BY PASSWORD = '<Private_Key_Password>'
	>       );
	> go
	> exit
	# scp /var/opt/mssql/data/dbm_certificate.* root@<server2 IP address>:/var/opt/mssql/data/
	# scp /var/opt/mssql/data/dbm_certificate.* root@<server3 IP address>:/var/opt/mssql/data/
	```
#### On secondary servers  
5. Chenge owner of certification files.  
	```bat
	# chown mssql:mssql /var/opt/mssql/data/dbm_certificate.*
	```
6. Create Certificate  
	```bat
	# sqlcms -U SA -P <SA password>
	> CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<Master_Key_Password>';
	> CREATE CERTIFICATE dbm_certificate   
	>    AUTHORIZATION dbm_user
	>    FROM FILE = '/var/opt/mssql/data/dbm_certificate.cer'
	>    WITH PRIVATE KEY (
	>    FILE = '/var/opt/mssql/data/dbm_certificate.pvk',
	>    DECRYPTION BY PASSWORD = '<Private_Key_Password>'
	>            );
	> go
	> exit
	```
#### On all servers
7. Create the database mirroring endpoints.  
	```bat
	# sqlcms -U SA -P <SA password>
	>CREATE ENDPOINT [Hadr_endpoint]
	>    AS TCP (LISTENER_PORT = <listener port number(default: 5022)>)
	>    FOR DATA_MIRRORING (
	>        ROLE = ALL,
	>        AUTHENTICATION = CERTIFICATE dbm_certificate,
	>        ENCRYPTION = REQUIRED ALGORITHM AES
	>        );
	>ALTER ENDPOINT [Hadr_endpoint] STATE = STARTED;
	>GRANT CONNECT ON ENDPOINT::[Hadr_endpoint] TO [dbm_login];
	> go
	>exit
	```
#### On primary server
8. Create Availability Group (ag)
	```bat
	# sqlcms -U SA -P <SA password>
	> CREATE AVAILABILITY GROUP <ag name>
	>    WITH (DB_FAILOVER = ON, CLUSTER_TYPE = NONE)
	>    FOR REPLICA ON
	>        N'<server1 name>' 
	>         WITH (
	>            ENDPOINT_URL = N'tcp://<server1 hostname>:<listener port number>',
	>            AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,
	>            FAILOVER_MODE = MANUAL,
	>            SEEDING_MODE = AUTOMATIC
	>            ),
	>        N'<server2 name>' 
	>         WITH ( 
	>            ENDPOINT_URL = N'tcp://<server2 hostname>:<listener port number>', 
	>            AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,
	>            FAILOVER_MODE = MANUAL,
	>            SEEDING_MODE = AUTOMATIC
	>            ),
	>        N'<server3 name>'
	>        WITH( 
	>           ENDPOINT_URL = N'tcp://<server3 hostname>:<listener port number>', 
	>           AVAILABILITY_MODE = SYNCHRONOUS_COMMIT,
	>           FAILOVER_MODE = MANUAL,
	>           SEEDING_MODE = AUTOMATIC
	>           );
	> go
	> exit
	```
#### On secondary servers
9. Join secondary servers to the ag
	```bat
	# sqlcms -U SA -P <SA password>
	> ALTER AVAILABILITY GROUP ag1 JOIN WITH (CLUSTER_TYPE = NONE);
	> ALTER AVAILABILITY GROUP ag1 GRANT CREATE ANY DATABASE;
	> go
	> exit
	```
10. Create database and its backup for initial replication and join it to the ag.
	```bat
	# sqlcms -U SA -P <SA password>
	> CREATE DATABASE <db name>;
	> ALTER DATABASE <db name> SET RECOVERY FULL;
	> BACKUP DATABASE <db name>
	>    TO DISK = N'/var/opt/mssql/data/<db name>.bak';
	> ALTER AVAILABILITY GROUP <ag name> ADD DATABASE <db name>;
	> go
	> exit
	```
#### On all servers
11. Confirm that only the database on the primary server is accessible.
	```bat
	# sqlcms -U SA -P <SA password>
	> USE <db name>;
	> go
	> exit
	```
Reference:
https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-availability-group-configure-ha

### Install EXPRESSCLUSTER and configure AG cluster
#### On all servers
1. Install EXPRESSCLUSTER and register its license.  
#### On a primary server
2. Start WebManager, create a cluster and apply it.  
  Regarding cluster configuration, please refer "Cluster Configuration" in the above.  
3. Activate failover group on the primary server.  

Reference:
https://www.nec.com/en/global/prod/expresscluster/en/support/manuals.html
- EXPRESSCLUSTER X 3.3 for Linux Installation and Configuration Guide
- EXPRESSCLUSTER X 3.3 for Linux Reference Guide

## Appendix

★Script

Refarence:
https://docs.microsoft.com/en-us/sql/database-engine/availability-groups/windows/monitor-availability-groups-transact-sql#AvGroups
https://docs.microsoft.com/en-us/sql/t-sql/statements/alter-availability-group-transact-sql?view=sql-server-2017
