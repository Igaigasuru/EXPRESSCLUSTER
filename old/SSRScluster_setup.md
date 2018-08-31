# How to setup MSSQL Server + SSRS Share Disk Cluster without Scale out deployment feature

## System environment
```bat
Windows Server 2016 Standard Edition
Microsoft SQL Server 2016 Standard Edition
EXPRESSCLUSTER X 3.3 for Windows (internal version: 11.34)
```
## System setup
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
				sd  
		1. Start group on Primary server  
1. MSSQL Server and SSRS installation
	1. On Primary server
		1. Install MSSQL Server
			- Feature Rules:
				- Select "Database Engine Services" and "Reporting service-Native "
			- Server Configuraiton:
				- Set "Manual" for service startup tyeps which will be clustered.  
					(e.g. SQL Server Database Engine and SQL Server Agent)  
			- Database Engine Configuration:
				- Add accounts which will be used from both Primary and Secondary server  
					(e.g. domain user for Windows authentication or sa account for SQL authentication)
				- Set \<Folder path which is on sd resource Data Partition\> for Data Root Directory
		1. Move group to Secondary server
	1. On Secondary server
		1. Install MSSQL Server
			- Feature Rules:
				- Select "Database Engine Services" and "Reporting service-Native"
			- Instance Configuration:
				- Set the same name and instance ID for the instance as Primary server
			- Server Configuraiton:
				- Set Manual startup for services which will be clustered.  
					(e.g. SQL Server Database Engine and SQL Server Agent)
			- Database Engine Configuration:
				- Add accounts which will be used from both Primary and Secondary server  
					(e.g. domain user for Windows authentication or sa account for SQL authentication)
				- Set \<Temporary folder\> for Data Root Directory
		1. Change SQL Server Startup Parameters
			1. Start SQL Server Configuration Manager
			1. Right click "SQLServer (<Instance Name>)", select "Properties" and go to "Startup Parameters" tab.
			1. Change Startup Parameters to the same as Primary Server setting  
				*Before*  
				　　-d\<Temporary folder\>\MSSQL12.MSSQLSERVER\MSSQL\DATA\master.mdf  
				　　-e\<Temporary folder\>\MSSQL12.MSSQLSERVER\MSSQL\Log\ERRORLOG  
				　　-l\<Temporary folder\>\MSSQL12.MSSQLSERVER\MSSQL\DATA\mastlog.ldf  
				*After*  
				　　-d\<Folder path which is on sd resource Data Partition\>\MSSQL12.MSSQLSERVER\MSSQL\DATA\master.mdf  
				　　-e\<Folder path which is on sd resource Data Partition\>\MSSQL12.MSSQLSERVER\MSSQL\Log\ERRORLOG  
				　　-l\<Folder path which is on sd resource Data Partition\>\MSSQL12.MSSQLSERVER\MSSQL\DATA\mastlog.ldf  
		1. Move group back to Primary server

1. SSRS Setup
	1. On Primary server
		1. Start SQL Server service and Reporting Services service  
		1. Start Reporting Service Configuration Manager and connect to the MSSQL Server instance  
			- Service Account:  
				Apply the default settings  
			- Web Service URL:  
				Apply the default settings  
			- Database:  
				Select "Create a new report server database"  
				Select local server as a Database Server  
				Set Report Server Database Name.
			- Web Portal URL:  
				Apply the default settings
			- Encryption Key:  
				Backup key file and store it under \<folder path which is on sd resource Data Partition\>
		1. Comfirm that you can connect to Report Server from a client
			- http://\<fip\>/Reports  
			http://\<fip\>/ReportServer
		1. Stop SQL Server service and Reporting Services service  
		1. Move group to Secondary server  
	1. On Secondary server
		1. Start SQL Server service and Reporting Services service  
		1. Copy Reporting Service parameter in config file from Primary Server to Secondary server.  
			- Config file path:  
				- \<MSSQL Server installation path\>\MSRS13.MSSQLSERVER\Reporting Services\ReportServer
			- Config file name:  
				- rsreportserver.config  
			- Target parameter:  
				- Installation ID
		1. Start Reporting Service Configuration Manager and connect to the MSSQL Server instance  
			- Service Account:  
				- Apply the default settings  
			- Web Service URL:  
				- Apply the default settings
			- Database:  
				- Select "Choose an existing report server database"  
				Select local server as a Database Server  
				Select Report Server Database which was created in step 3.i.b.  
			- Web Portal URL:  
				- Apply the default settings
			- Encryption Key:  
				- Restore backup key file which was created in step 3.i.b.
		1. Comfirm that you can connect to Report Server from a client
			- http://\<fip\>/Reports  
			http://\<fip\>/ReportServer
		1. Stop SQL Server service and Reporting Services service  
		1. Move group back to Primary server  
1. MSSQL cluster setup
	1. On Primary server
		1. Add resources to group
			- service_sql
				- Target service:  SQL Server  
				Start/Stop:  synchronous
			- service_agent: MSSQL Server
				- Target service:  SQL Server Agent  
				Start/Stop:  synchronous
			- service_report:
				- Target service: SQL Server Reporting Services  
				Start/Stop:  synchronous
			- script:
				- start.bat:  
				Execute "rskermgmt -a" command to restore key.  
				Refer the appendix sample script.  
				- stop.bat:  No need to set.
				- Start/Stop:  synchronous
		1. Change resource dependency as the below:  
			- 0  fip  
			1  sd  
			2  service_sql  
			3  service_agent  
			4  service_report  
			5  script  
		1. Apply the configuration and confirm cluster behaviour.
## Appendix
Sample script for start.bat:  
```bat
rskeymgmt -a -f <backup key file path> -p <password>  
  
if %ERRORLEVEL%=0 (  
 exit 0  
) else (  
 exit 1  
)  
```
