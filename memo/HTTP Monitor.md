# How to monitor HTTP with genw on Windows
1. Store Powershell script to check HTTP reply (sample) on all cluster servers.  
  e.g.) C:\Program Files\EXPRESSCLUSTER\scripts\httpmonitor\httpmon.ps1
1. Change all cluster servers Powershell Script Execution Policy to enable httpmon.ps1 execution.
1. Add genw to cluster with the settings below:  
    - Monitor Timing: Active
    - Monitor Target: Sesource for Web service (such as IIS service)
    - genw.bat: [Sample](https://github.com/Igaigasuru/EXPRESSCLUSTER/blob/master/memo/script/genw_httpmon.bat)
