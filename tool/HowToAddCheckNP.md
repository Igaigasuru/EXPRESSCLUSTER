1. Add exec resource
 - Type: exec resource
 - Name: exec_checkNP
 - Follow the default dependency: Uncheck
 - Recovery Operation at Activation Failure DetectionRetry Count: 1
  - Failover Threshold: 0
  - Final Action: Stop the cluster service and reboot OS
  - start.sh: Refer [exec_checkNP_stat.sh](https://github.com/Igaigasuru/EXPRESSCLUSTER/blob/master/tool/exec_checkNP_stat.sh) \(Option [exec_checkNP_ping.sh](https://github.com/Igaigasuru/EXPRESSCLUSTER/blob/master/tool/exec_checkNP_ping.sh)\)
- Tuning button
    -> Start Script Tierout: 90
    -> Maintenance tab -> Logoutput Path: /opt/nec/clusterpro/log/exec_checkNP.log
                          Rotate Log: Check

2. Change existing resources Dependency
Change existing resources Dependency to start exec_checkNP resource first in the Group.

3. Change Cluster Properties
 Cluster Properties -> NP Resolution tab -> Tuning button
 -> Action at NP Occurrence: Stop the cluster service and reboot OS

4. Edit nm.pol file on all nodes
```bat
# vi /opt/nec/clusterpro/etc/policy/nm.pol
<pingnpaction> 2 </pingnpaction>
```

5. Apply the changes
When applying the updated config, cluater suspend/resume and group stop/start will be required.
