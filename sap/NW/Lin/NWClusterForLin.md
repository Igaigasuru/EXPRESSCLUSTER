# SAP Netweaver cluster

## Overview
This article shows a setup flow of 2 nodes SAP Netweaver cluster on Linux with 1 NFS Server.

## System Configuratin
```bat
<LAN>
 |
 |  +----------------------------+
 +--| Primary Server             |
 |  | - Linux OS                 |
 |  | - SAP NetWeaver            |
 |  | - EXPRESSCLUSTER X 4.1     |
 |  +----------------------------+
 |                                       +----------------------------+
 +---------------------------------------| DB Server                  |
 |                                       |                            |
 |                                       +----------------------------+
 |
 |                                       +----------------------------+
 +---------------------------------------| NFS Server                  |
 |                                       |                             |
 |                                       +----------------------------+
 |  +----------------------------+
 +--| Secondary Server           |
 |  | - Linux OS                 |
 |  | - SAP NetWeaver            |
 |  | - EXPRESSCLUSTER X 4.1     |
 |  +----------------------------+
 |
```

## Note
- DB Server and NFS Serer are used by SAP NetWeaver and should be accessible from both Primary and Secondary Servers.
- DB Server setup is out of scope of this article.
	For more details about DB Server (System requirements, compatibles, howto setup ...etc), check SAP NetWeaver Guide.
- DB Server setup is used by NetWeaver is out of scope of this article.
  However, configure mount point accoding to this article becasue NFS Server is access by SAP NetWeaver to read the same SAP instance profiles on both Primary and Secondary Servers.

## Reference
- About NW Master Guide:  
  https://websmp201.sap-ag.de/~sapidb/012002523100015815162015E.pdf
- About NW Installation Guide:  
  http://service.sap.com/installnw75/
- About ENSA2:  
	https://help.sap.com/viewer/cff8531bc1d9416d91bb6781e628d4e0/201809.000/en-US/7aa4fc5e9e6047edb0505c59d968ca54.html

## Setup

### Parameters

#### SAP NW

SAP System ID (SID):	NEC

Instances
- ASCS Instance
	Instance ID (INO):	10
	Instance Name:	ASCS10
	Hostname:	ascssv (assigned to fip1)
- ERS Instance
	Instance ID (INO):	20
	Instance Name:	ERS20
	Hostname:	erssv (assigned to fip2)
- PAS Instance
	Instance ID (INO):	30
	Instance Name:	D30
- AAS Instance
	Instance ID (INO):	40
	Instance Name:	D40
- DA1 Instance
	Instance ID (INO):	97
	Instance Name:	SMDA97
- DA2 Instance
	Instance ID (INO):	96
	Instance Name:	SMDA96

#### ECX

Failover groups
- ASCS-Group
- ERS-Group
- PAS-Group
- AAS-Group
- DA1-Group
- DA2-Group

### Preparation
On NFS Server

1. Setup NFS Server  
	1. Install NFS Server
	1. Create and export the following folders:  
		- /opt/nfsroot/sapmnt/NEC
		- /opt/nfsroot/saptrans

On both nodes

1. Disable SE Linux

1. Install mandatory features
	```bat
	# yum groupinstall <Group Name>
		#Group Name
		base
		compat-libraries
		debugging
		directory-client
		hardware-monitoring
		large-systems
		network-file-system-client
		perl-runtime
		storage-client-multipath
		x11
	# yum install uuidd.x86_64
	# systemctl start uuidd
	# systemctl enable uuidd
	```

1. Edit DNS Server record or hosts file to enable the following Name Resolution
	```bat
	---------------------------------------+------------------------
	IP Address				Hostname
	---------------------------------------+------------------------
	<node1 actual IP Address>		<node1 actual hostname>
	<node2 actual IP Address>		<node2 actual hostname>
	fip1 (for ASCS)				ascssv
	fip2 (for ERS)				erssv
	---------------------------------------+------------------------
	```

1. Mount NFS Server
	1. Create the following mount points
		```bat
		# mkdir -p /sapmnt/NEC
		# mkdir -p /usr/sap/trans
		# mkdir -p /usr/sap/NEC/ASCS10
		```

	1. Edit fstab
		```bat
		# vi /etc/fstab
		  <NFS Server IP Address>:/opt/nfsroot/sapmnt/NEC /sapmnt/NEC nfs defaults 0 0
		  <NFS Server IP Address>:/opt/nfsroot/saptrans  /usr/sap/trans  nfs defaults 0 0
		```

1. Edit kernel parameter
	```bat
	# vi /etc/sysctl.d/sap.conf
		# SAP settings
		kernel.sem=1250 256000 100 1024
		vm.max_map_count=2000000
	# sysctl ?system
	```

1. Edit limits.conf
	```bat
	# vi /etc/security/limits.conf
		@sapsys          hard    nofile          32800
		@sapsys          soft    nofile          32800
	```

1. Create Symbolic Link (Pease refer SAP NW installtion guide about the detail)
	```bat
	# ln -s /sapmnt/NEC /usr/sap/NEC/SYS
	```

### ECX basic installation

On both nodes

1. Install ECX and register licenses

1. Install Connector for SAP
	```bat
	rpm -i expresscls_spnw-<ECX version>.x86_64.rpm
	```
	or, store the files as the below.
	```bat
	/opt/nec/clusterpro/bin/clp_shi_connector
	/opt/nec/clusterpro/etc/clp_shi_connector.conf
	/opt/nec/clusterpro/bin/clp_shi_connector_wrapper
	```

1. Create the following failover groups:  
	- ASCS-Group
	- ERS-Group

1. Add fip to the both goups.
	- ASCS-Group
		- fip-ascssv
	- ERS-Group
		- fip-erssv

1. Activate both groups on node1.

### SAP NW installation

1. Install ASCS instance with ascs virtualhostname on node1
	```bat
	# env SAPINST_USE_HOSTNAME=ascssv ./sapinst
	```
	- Refer "Parameters" for Instance ID (INO), Instance Name and virtual hostname for ASCS.
	- If installation path is required, specify "/sapmnt/NEC".

1. Install ERS instance with ers virtualhostname on both node1
	```bat
	# env SAPINST_USE_HOSTNAME=erssv ./sapinst
	```
	- Refer "Parameters" for Instance ID (INO), Instance Name and virtual hostname for ERS.
	- If installation path is required, specify "/sapmnt/NEC".

1. If ENSA is installed, update to ENSA2

1. Install PAS on node1
	```bat
	# ./sapinst
	```
	- Refer "Parameters" for Instance ID (INO) and Instance Name.
	- If installation path is required, specify "/sapmnt/NEC".

1. Install AAS on node2
	```bat
	# ./sapinst
	```
	- Refer "Parameters" for Instance ID (INO) and Instance Name.
	- If installation path is required, specify "/sapmnt/NEC".

1. Edit all SAP instance profiles on NFS Server as the below:
	```bat
	#vi /sapmnt/NEC/profile/NEC_ERS20_erssv
		service/halib = /usr/sap/<SID>/<Instance name><INO>/exe/saphascriptco.so
		service/halib_cluster_connector = /opt/nec/clusterpro/bin/clp_shi_connector_wrapper
	```
1. Edit all DA instance profiles on both nodes as the below:
	```bat
	# /usr/sap/<DASID>/SYS/profile/NEC_<Instance name><INO>_<hostname>
		service/halib = /usr/sap/hostctrl/exe/saphascriptco.so
		service/halib_cluster_connector = /opt/nec/clusterpro/bin/clp_shi_connector_wrapper
	```
1. Give sudo permission on SAP NW user account to enable Connector for SAP by executing the following command:
	```bat
	# visudo
		Defaults:%sapsys        !requiretty

		%sapsys ALL=(ALL)       NOPASSWD: ALL
	```
1. Give sudo permission on user group which is created whole SAP NW installation.

1. Register SAP License.

1. Disable SAP instance services auto startup on both Servers.
	```bat
	# systemctl disable sapinit
	# chkconfig --list sapinit
	sapinit         0:off   1:off   2:off   3:off   4:off   5:off   6:off
	```

1. Disable ERS instance auto startup on both Servers.
	```bat
	# vi /sapmnt/NEC/profile/NEC_ERS20_erssv
		Autostart=0
	```

1. Disable DA instances auto startup on both Servers.
	```bat
	# vi /usr/sap/<DA SID>/SYS/profile/<DA SID>_SMDA<INO>_<hostname>
		Autostart=0
	```

1. Enable ERS instance auto stop on both Servers.
	```bat
	# vi /sapmnt/NEC/profile/NEC_ERS20_erssv
		# Restart_Program_00 = local $(_ER) pf=$(_PFL) NR=$(SCSID)
		Start_Program_00 = local $(_ER) pf=$(_PFL) NR=$(SCSID)
	```

### Cluster setup
