# SAP Netweaver cluster

## Overview
This article shows a setup flow of 2 nodes SAP Netweaver cluster on Linux with 1 NFS Server.

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
- PAS Instance (*)
	Instance ID (INO):	30
	Instance Name:	D30
- AAS Instance (*)
	Instance ID (INO):	40
	Instance Name:	D40
- DA1 Instance (*)
	Instance ID (INO):	97
	Instance Name:	SMDA97
- DA2 Instance (*)
	Instance ID (INO):	96
	Instance Name:	SMDA96

	\* If AAS/PAS are not required for this nodes (installation is not required or installed on another nodes), please ignore.

#### ECX

Failover groups
- ASCS-Group
- ERS-Group
- PAS-Group (*)
- AAS-Group (*)
- DA1-Group (*)
- DA2-Group (*)
- hostexec1-Group
- hostexec2-Group

	\* If AAS/PAS are not required for this nodes (installation is not required or installed on another nodes), please ignore.

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

1. Create the following failover groups:  
  - ASCS-Group
  - ERS-Group

1. Add fip to the both goups.

1. Activate both groups on node1.


### SAP NW installation

1. Install ASCS instance with ascs virtualhostname on node1
	```bat
	# env SAPINST_USE_HOSTNAME=ascssv ./sapinst
	```
	- Refer "Parameters" for Instance ID (INO), Instance Name and virtual hostname for ASCS.
	- If installation path is required, ★

1. Install ERS instance with ers virtualhostname on node1
	```bat
	# env SAPINST_USE_HOSTNAME=erssv ./sapinst
	```

1. Install PAS on node1 (*)
	```bat
	# ./sapinst
	```

1. Install AAS on node1 (*)
	```bat
	# ./sapinst
	```

	* If AAS/PAS are not required for this nodes (installation is not required or installed on another nodes), please ignore.
