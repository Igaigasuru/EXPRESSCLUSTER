# How to monitor HTTP with genw on EXPRESSCLUSTER for Windows

## Without Authentication
### Preparation for Powershell script
1. Store Powershell script to check HTTP reply ([sample](https://github.com/Igaigasuru/EXPRESSCLUSTER/blob/master/memo/script/httpmon.ps1)) on all cluster servers.  
  e.g.) C:\Program Files\EXPRESSCLUSTER\scripts\httpmonitor\httpmon.ps1
1. Change all cluster servers Powershell Script Execution Policy to enable httpmon.ps1 execution.
### Cluster settings
1. Add genw to cluster with the settings below:  
    - Monitor Timing: Active
    - Monitor Target: Resource for Web service (such as IIS service)
    - genw.bat: [Sample](https://github.com/Igaigasuru/EXPRESSCLUSTER/blob/master/memo/script/genw_httpmon.bat)

## With Authentication
### Preparation for Powershell script
1. Store Powershell script to check HTTP reply ([sample](https://github.com/Igaigasuru/EXPRESSCLUSTER/blob/master/memo/script/httpmon.ps1)) on all cluster servers.  
  e.g.) C:\Program Files\EXPRESSCLUSTER\scripts\httpmonitor\httpmon.ps1
1. Change all cluster servers Powershell Script Execution Policy to enable httpmon.ps1 execution.

### Create password file for the authentication
1. Log on to Primary Server (or any other machine) with an account which has a permission to access the HTTP Server and execute the following command. Then an encrypted password file will be created.  
  ```bat
  Read-Host -prompt "Enter password" -AsSecureString | ConvertFrom-SecureString -Key (1..16) | Out-File <File Path>
  ```
1. Copy the password file and paste it on all cluster servers.  
  e.g.) C:\tmp\sec_key.txt (on all servers)

### Cluster settings
1. Add genw to cluster with the settings below:  
    - Monitor Timing: Active
    - Monitor Target: Resource for Web service (such as IIS service)
    - genw.bat: [Sample](https://github.com/Igaigasuru/EXPRESSCLUSTER/blob/master/memo/script/genw_httpmon.bat)

## Reference (in Japanese)
https://qiita.com/hidehara/items/3847132ea0745a751435  
https://qiita.com/Kill_In_Sun/items/0f1798d42dbd35d248e9  
https://social.technet.microsoft.com/Forums/ja-JP/12e5ada3-5fc6-46c5-a504-e8d51719cad1/invokewebrequest203512999226178123981230012475124611251712522124861?forum=powershellja
