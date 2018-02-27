# HA DBMS Demo Toolkit (PostgreSQL)

## Overview
HA DBMS Demo Toolkit (PostgreSQL) is demo tool for PostgreSQL DB Cluster.
Please refer the below for how to use it.

## System configuration


## System environment
### PosgreSQL Server Cluster  
Please refer: [How to setup PostgreSQL DB Cluster](https://github.com/Igaigasuru/EXPRESSCLUSTER/blob/master/PostgreCluster_setup.md "Title")
### PosgreSQL Client  
```bat
Windows Server 2016 Standard Edition  
Apache 2.4.29 (Win64)  
PHP 7.2.1  
Mozilla Firefox 58.0.2 for 64-bit  
```
	
## System setup  

### PostgreSQL Server Cluster  
Please refer: [How to setup PostgreSQL DB Cluster](https://github.com/Igaigasuru/EXPRESSCLUSTER/blob/master/PostgreCluster_setup.md "Title")

### PostgreSQL Client  

1. Install php  
	1. Store php folder on the client machine.
		e.g.) C:\php
	1. Add the folder path ";C\php" to Environment Variables, "Path" in System variables.
	1. Copy and rename "C:\php\php.ini-production" file to "C:\php\php.ini".
	1. If you store php folder othert than under C:, replace all "C:\" (default path) in "php.ini" file to actual path.
	1. Try php command on command promptand and confirm it works.
		```bat
		C:\Users\Administrator>php -v
		```
1. Intall Apache  
	1. Store Apache folder on the client machine.
		e.g.) C:\Apache24
	1. If you store Apache folder othert than under C:, please replace all "C:\" (default path) in "<Install path>\Apache24\conf\httpd.conf" file to actual path.
	1. Start comand prompt as an administrator, move to bin folder and install Apache service with the following command.
		```bat
		C:\Users\Administrator>cd C:\Apache24\bin
		C:\Apache24\bin>httpd.exe -k install
		```
	1. Execute "C:\Apache24\bin\ApacheMonitor.exe" and start Apache service.
	1. Start FireFox browser and access the following URL and confirm Apache Web server works.
		```bat
		http://localhost/
		```
1. Change php setteings to enable demo tool.
	1. Edit the "php.ini" as the below:  
		```bat  
		mbstring.internal_encoding = utf-8
		mbstring.http_output = utf-8
		
		output_buffering = On
		output_handler = mb_output_handler
		
		max_execution_time = 0
		
		display_errors = Off
		```
1. Change Apache setteings to use enable php on Apache Web server.
	1. Edit the "httpd.conf" as the below:  
		```bat  
		Listen 127.0.0.1:80
		
		<Directory />
		    AllowOverride All
		    Require all granted
		</Directory>
		
		<IfModule dir_module>
		    DirectoryIndex index.html index.php
		</IfModule>
		```
	1. Add the following at the end of "httpd.conf":
		```bat
		LoadModule php7_module "c:/php/php7apache2_4.dll"
		AddHandler application/x-httpd-php .php
		
		PHPIniDir "C:/php"
		```
	1. Check the syntax error in "httpd.conf" and with the following command. (By restarting from CLI, you can confirm syntax error.)
		```bat
		httpd.exe -t
		```
	1. Create new php file under "<Apache installation path>\Apache24\htdocs".
		e.g.) C:\Apache24\htdocs\phpinfo.php
		And write in the file as the following.
		```bat
		<?php phpinfo(); ?>
		```
	1. Start FireFox browser and access the following URL and confirm php information is displayed.
		```bat
		http://localhost/phpinfo.php
		```
1. Create DB table for demo
	1. On Active Postgre SQL Server, create db table which has 2 columns named "name(varchar)" and "number(int)" 
		```bat
		# su - postgres
		$ /usr/pgsql-10/bin/psql -U postgres -d db1
		db1-# CREATE TABLE demotable(
		db1-# name varchar(20) NULL,
		db1-# number int NULL
		db1-# );
		db1-# INSERT into demotable values ('Kurara', 0);
		db1-# \q
		```
1. Use Demo Tool
	1. Download [Demo tool](https://github.com/Igaigasuru/EXPRESSCLUSTER/blob/master/tool/PostgreClusterDemo.php "Title") and store it under "C:\Apache24%\htdocs\".
		```bat
		C:\Apache24%\htdocs\Demo\ClusterDemo.php
		```
	1. Start FireFox brouwser and access to the URL.
		```bat
		http://localhost/Demo/ClusterDemo.php
		```
	1. Set fip of PostgreSQL Server Cluster.
	1. Click "Start".
