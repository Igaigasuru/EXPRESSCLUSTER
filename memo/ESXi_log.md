# HAUC ESXi ログの見方メモ
HAUC でよく見る ESXi ログの見るポイントメモ。

## 注意と補足と覚書
- vCenter は使われていないので、VM の操作系は基本 hostd.log。  
  （vCenter からの操作だと vpxa で、ログの出方も変わりそう？）
- ESXi 6.5 から hostd.log にやたら「Applied change to temp map」みたいなログが出るようになってるから、map とやらを持ってるっぽい?  
- ログの抜粋は適当だから前後ちゃんと見て。

## LAN ケーブルのリンクダウン・アップ
vmkernel.log を 「NIC Link」で検索。Down か Up か。
```bat
2018-07-05T20:58:06.093Z cpu27:66317)<6>igb: vmnic_110100 NIC Link is Down  
2018-07-05T21:02:41.727Z cpu28:66315)<6>igb: vmnic_110100 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX  
```

## VM のステータス変化
hostd.log を「State Transition (」で検索する。

VM のインベントリ追加（Register）。
```bat
2018-07-05T21:06:22.793Z info hostd[9F81B70] [Originator@6876 sub=Vimsvc.TaskManager opID=vim-cmd-fc-243c user=dcui] Task Created : haTask-ha-folder-vm-vim.Folder.registerVm-107999318  
2018-07-05T21:06:22.793Z info hostd[AA81B70] [Originator@6876 sub=Solo.HaVMFolder opID=vim-cmd-fc-243c user=dcui] Register called: []/vmfs/volumes/5b2cf72d-c314ef74-0f37-8cdf9d51786c/gnav-10.1/gnav-10.1.vmx  
2018-07-05T21:06:22.870Z info hostd[A6C2B70] [Originator@6876 sub=Vmsvc.vm:/vmfs/volumes/5b2cf72d-c314ef74-0f37-8cdf9d51786c/gnav-10.1/gnav-10.1.vmx opID=vim-cmd-fc-243c user=dcui] State Transition (VM_STATE_INITIALIZING -> VM_STATE_OFF)  
2018-07-05T21:06:22.875Z info hostd[A6C2B70] [Originator@6876 sub=Vimsvc.ha-eventmgr opID=vim-cmd-fc-243c user=dcui] Event 2215 : Registered gnav-10.1 on localhost.localdomain in ha-datacenter  
2018-07-05T21:06:22.876Z info hostd[A6C2B70] [Originator@6876 sub=Vimsvc.TaskManager opID=vim-cmd-fc-243c user=dcui] Task Completed : haTask-ha-folder-vm-vim.Folder.registerVm-107999318 Status success  
```

VM をパワーオン。
```bat
2018-07-05T21:55:18.660Z info hostd[9BC1B70] [Originator@6876 sub=Vimsvc.TaskManager opID=ecb6776e user=root] Task Created : haTask-99-vim.VirtualMachine.powerOn-108005254  
2018-07-05T21:55:18.661Z info hostd[6C88890] [Originator@6876 sub=Vimsvc.ha-eventmgr opID=ecb6776e user=root] Event 3673 : v-queworx_a on host localhost.localdomain in ha-datacenter is starting  
2018-07-05T21:55:18.661Z info hostd[6C88890] [Originator@6876 sub=Vmsvc.vm:/vmfs/volumes/5b2cf72d-c314ef74-0f37-8cdf9d51786c/v-queworx_a/v-queworx_a.vmx opID=ecb6776e user=root] State Transition (VM_STATE_OFF -> VM_STATE_POWERING_ON)  
2018-07-05T21:55:18.928Z info hostd[6C88890] [Originator@6876 sub=Vimsvc.ha-eventmgr] Event 3674 : v-queworx_a on  localhost.localdomain in ha-datacenter is powered on  
2018-07-05T21:55:18.928Z info hostd[6C88890] [Originator@6876 sub=Vmsvc.vm:/vmfs/volumes/5b2cf72d-c314ef74-0f37-8cdf9d51786c/v-queworx_a/v-queworx_a.vmx] State Transition (VM_STATE_POWERING_ON -> VM_STATE_ON)  
```

VM のパワーオフ。
```bat
2018-07-05T20:55:44.732Z info hostd[AAC2B70] [Originator@6876 sub=Vimsvc.TaskManager opID=vim-cmd-58-1110 user=dcui] Task Created : haTask-95-vim.VirtualMachine.powerOff-107998012  
2018-07-05T20:55:44.733Z info hostd[A240B70] [Originator@6876 sub=Vimsvc.ha-eventmgr opID=vim-cmd-58-1110 user=dcui] Event 1908 : MGSIP EOSN OUT on  localhost.localdomain in ha-datacenter is stopping  
2018-07-05T20:55:44.733Z info hostd[A240B70] [Originator@6876 sub=Vmsvc.vm:/vmfs/volumes/5b2cf72d-c314ef74-0f37-8cdf9d51786c/MGSIP EOSN OUT/MGSIP EOSN OUT.vmx opID=vim-cmd-58-1110 user=dcui] State Transition (VM_STATE_ON -> VM_STATE_POWERING_OFF)  
2018-07-05T20:55:45.409Z info hostd[A2C2B70] [Originator@6876 sub=Vimsvc.TaskManager] Task Completed : haTask-95-vim.VirtualMachine.powerOff-107998012 Status success  
```

VM のインベントリ削除（unregister）
```bat
2018-07-05T20:55:46.093Z info hostd[9B80B70] [Originator@6876 sub=Vimsvc.TaskManager opID=vim-cmd-24-1191 user=dcui] Task Created : haTask-96-vim.VirtualMachine.unregister-107998040  
2018-07-05T20:55:46.094Z info hostd[9B80B70] [Originator@6876 sub=Vmsvc.vm:/vmfs/volumes/5b2cf72d-c314ef74-0f37-8cdf9d51786c/MGSIP EOSN IN/MGSIP EOSN IN.vmx opID=vim-cmd-24-1191 user=dcui] State Transition (VM_STATE_OFF -> VM_STATE_UNREGISTERING)  
2018-07-05T20:55:46.098Z info hostd[9B80B70] [Originator@6876 sub=Vimsvc.ha-eventmgr opID=vim-cmd-24-1191 user=dcui] Event 1916 : Removed MGSIP EOSN IN on localhost.localdomain from ha-datacenter  
2018-07-05T20:55:46.098Z info hostd[9B80B70] [Originator@6876 sub=Vmsvc.vm:/vmfs/volumes/5b2cf72d-c314ef74-0f37-8cdf9d51786c/MGSIP EOSN IN/MGSIP EOSN IN.vmx opID=vim-cmd-24-1191 user=dcui] State Transition (VM_STATE_UNREGISTERING -> VM_STATE_GONE)  
2018-07-05T20:55:46.099Z info hostd[9B80B70] [Originator@6876 sub=Vimsvc.TaskManager opID=vim-cmd-24-1191 user=dcui] Task Completed : haTask-96-vim.VirtualMachine.unregister-107998040 Status success  
```

## VM の Question Pending (ポップアップ的ななんかの操作待ち)
これも hostd.log。
出たときは Message on で検索。出てきてるメッセージもログに記録される。
```bat
2018-07-05T20:53:34.441Z info hostd[A640B70] [Originator@6876 sub=Vimsvc.ha-eventmgr] Event 1787 : Message on MGSIP EOSN OUT on localhost.localdomain in ha-datacenter: This virtual machine might have been moved or copied.
--> In order to configure certain management and networking features, VMware ESX needs to know if this virtual machine was moved or copied.
-->
--> If you don't know, answer "I Co_pied It".
-->
-->
2018-07-05T20:53:34.441Z verbose hostd[A640B70] [Originator@6876 sub=PropertyProvider] RecordOp ASSIGN: runtime.question, 95. Sent notification immediately.
```

応答は answer で検索。
```bat
2018-07-05T20:53:46.979Z info hostd[9F81B70] [Originator@6876 sub=Vimsvc.TaskManager opID=ecb60b17 user=root] Task Created : haTask-95-vim.VirtualMachine.answer-107997594
2018-07-05T20:53:46.979Z info hostd[9F81B70] [Originator@6876 sub=Vmsvc.vm:/vmfs/volumes/5b2cf72d-c314ef74-0f37-8cdf9d51786c/MGSIP EOSN OUT/MGSIP EOSN OUT.vmx opID=ecb60b17 user=root] Received answer: 79900, 1
2018-07-05T20:53:46.996Z info hostd[8EC2B70] [Originator@6876 sub=Vmsvc.vm:/vmfs/volumes/5b2cf72d-c314ef74-0f37-8cdf9d51786c/MGSIP EOSN OUT/MGSIP EOSN OUT.vmx] Answered user-visible question 79900
2018-07-05T20:53:46.996Z info hostd[8EC2B70] [Originator@6876 sub=Vimsvc.TaskManager] Task Completed : haTask-95-vim.VirtualMachine.answer-107997594 Status success
```

## データストアの All Path Down
早いのは hostd.log を All Paths で検索。enter か exit か。
ただし、実際にパス切れてから APD と断定されるまで Timeout 10sec あるっぽいので、実際に切れた時間見るなら vmkernel を「being marked "」で検索がいいかも。
そのほか細かいこと見るにも vmkernel。

SCSI 応答なくなる @vmkernel.log
```bat
2018-07-06T21:02:01.201Z cpu14:66536)WARNING: iscsi_vmk: iscsivmk_ConnReceiveAtomic: vmhba64:CH:0 T:0 CN:0: Failed to receive data: Connection closed by peer
2018-07-06T21:02:01.201Z cpu14:66536)WARNING: iscsi_vmk: iscsivmk_ConnReceiveAtomic: Sess [ISID: 00023d000001 TARGET: iqn.2018-03.nec.com: TPGT: 1 TSIH: 0]
2018-07-06T21:02:01.201Z cpu14:66536)WARNING: iscsi_vmk: iscsivmk_ConnReceiveAtomic: Conn [CID: 0 L: 172.31.254.21:58200 R: 172.31.254.10:3260]
2018-07-06T21:02:01.202Z cpu14:66536)iscsi_vmk: iscsivmk_ConnRxNotifyFailure: vmhba64:CH:0 T:0 CN:0: Connection rx notifying failure: Failed to Receive. State=Online
2018-07-06T21:02:01.202Z cpu28:66292)WARNING: iscsi_vmk: iscsivmk_StopConnection: vmhba64:CH:0 T:0 CN:0: iSCSI connection is being marked "OFFLINE" (Event:6)
2018-07-06T21:02:01.265Z cpu2:66518)NMP: nmp_ThrottleLogForDevice:3617: Cmd 0x2a (0x43950c44a000, 65575) to dev "naa.60014055c425cd10a874374b415629b3" on path "vmhba64:C0:T0:L0" Failed: H:0x2 D:0x0 P:0x0 Invalid sense data: 0x0 0x0 0x0. Act:EVAL
2018-07-06T21:02:01.265Z cpu2:66518)WARNING: NMP: nmp_DeviceRequestFastDeviceProbe:237: NMP device "naa.60014055c425cd10a874374b415629b3" state in doubt; requested fast path state update...
```

10秒後に APD と断定 @vmkernel.log
```bat
2018-07-06T21:02:11.204Z cpu0:65641)HBX: 6214: APD EventType: APD_START (3) for vol 'iSCSI'
2018-07-06T21:02:11.204Z cpu0:65641)ScsiDevice: 4993: Device state of naa.60014055c425cd10a874374b415629b3 set to APD_START; token num:1
2018-07-06T21:02:11.204Z cpu0:65641)StorageApdHandler: 1205: APD start for 0x4302ff581ad0 [naa.60014055c425cd10a874374b415629b3]
```

断定されると hostd にも出るよ @hostd.log
```bat
2018-07-06T21:02:11.204Z info hostd[B781B70] [Originator@6876 sub=Vimsvc.ha-eventmgr] Event 3026 : Device or filesystem with identifier naa.60014055c425cd10a874374b415629b3 has entered the All Paths Down state.
```

APD からの復帰 @vmkernel
```bat
2018-07-06T21:02:22.556Z cpu31:66696)WARNING: iscsi_vmk: iscsivmk_StartConnection: vmhba64:CH:0 T:0 CN:0: iSCSI connection is being marked "ONLINE"
2018-07-06T21:02:22.556Z cpu31:66696)WARNING: iscsi_vmk: iscsivmk_StartConnection: Sess [ISID: 00023d000001 TARGET: iqn.2018-03.nec.com: TPGT: 1 TSIH: 0]
2018-07-06T21:02:22.556Z cpu31:66696)WARNING: iscsi_vmk: iscsivmk_StartConnection: Conn [CID: 0 L: 172.31.254.21:18064 R: 172.31.254.10:3260]
2018-07-06T21:02:22.556Z cpu0:65642)ScsiDevice: 5015: Setting Device naa.60014055c425cd10a874374b415629b3 state back to 0x2
2018-07-06T21:02:22.556Z cpu0:65642)ScsiDevice: 5036: Device naa.60014055c425cd10a874374b415629b3 is Out of APD; token num:1
2018-07-06T21:02:22.559Z cpu2:65629)HBX: 6214: APD EventType: APD_EXIT (4) for vol 'iSCSI'
```

復帰しても hostd に出るよ @hostd.log
```bat
2018-07-06T21:02:22.566Z info hostd[B381B70] [Originator@6876 sub=Vimsvc.ha-eventmgr] Event 3031 : Device or filesystem with identifier naa.60014055c425cd10a874374b415629b3 has exited the All Paths Down state.
```

## ssh 接続
auth.log で接続元 IP とかで検索すれば。それか実行したコマンド。
```bat
2018-07-05T20:12:46Z sshd[77731]: Connection from 172.31.255.6 port 50311
2018-07-05T20:12:46Z sshd[77731]: User 'root' running command 'vim-cmd vmsvc/power.getstate 91 2>&1'
2018-07-05T20:12:46Z sshd[77731]: Disconnected from 172.31.255.6 port 50311
```
