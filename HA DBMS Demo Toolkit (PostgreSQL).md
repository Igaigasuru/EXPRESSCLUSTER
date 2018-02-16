# HA DBMS Demo Toolkit (PostgreSQL)

## Overview
HA DBMS Demo Toolkit (PostgreSQL) is demo tool for PostgreSQL DB Cluster.
Please refer the below for how to use it.

##System configuration


## System environment
- PosgreSQL DB Cluster  
	Please refer: [How to setup PostgreSQL DB Cluster](https://github.com/Igaigasuru/EXPRESSCLUSTER/blob/master/PostgreCluster_setup.md)
- PosgreSQL DB Client  
	```bat
		Windows Server 2016 Standard Edition  
		Apache 2.4.29 (Win64)  
		PHP 7.2.1  
		Internet Explorer 11 (11.0.37) / Mozilla Firefox 58.0.2 for 64-bit  
	```

## System setup

1. PostgreSQL DB Cluster setup  
		Please refer: [How to setup PostgreSQL DB Cluster](https://github.com/Igaigasuru/EXPRESSCLUSTER/blob/master/PostgreCluster_setup.md)


1. PostgreSQL DB Client setup  
	1. Install Apache and PHP.  
		e.g.) C:\php, C:\Apache24
	1. Change Apache setting to use PHP.
		1. Edit the "C:\Apache24\conf\httpd.conf" as the below:  
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
		1. Add the following at the end of "C:\Apache24\conf\httpd.conf":
			```bat
			LoadModule php7_module "c:/php/php7apache2_4.dll"
			AddHandler application/x-httpd-php .php
			
			PHPIniDir "C:/php"
			```
		1. Restart Apache service to apply the settings.
			```bat
			httpd.exe -k restart
			```
	1. Change PHP setting to use PHP.
		1. Edit the "C:\php\php.ini" as the below:  
			```bat  
			mbstring.internal_encoding = utf-8
			mbstring.http_output = utf-8
			
			output_buffering = On
			output_handler = mb_output_handler
			
			max_execution_time = 0
			
			display_errors = Off
			```
	1. Store Demo tool.
		1. Download fomr [here](https://github.com/Igaigasuru/EXPRESSCLUSTER/blob/master/tool/PostGreClusterDemo.php)
		1. Store the files under " C:\Apache24%\htdocs\".
			```bat
			C:\Apache24%\htdocs\Demo\ClusterDemo.php
			```
	1. Run the tool.
		1. Open the tool with a browser.
			```bat
			http://localhost/Demo/ClusterDemo.php
			```
		1. Set fip of PostgreSQL Cluster
		1. Click "Start".
