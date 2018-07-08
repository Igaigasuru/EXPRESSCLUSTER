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
hostd.log を All Paths で検索。enter か exit か。
All Path Down じゃないデータストア以上はたぶん vmkernel.log に出る。データストア名とか UUID とかで検索すればたぶん見つかる。
```bat
2018-07-05T21:15:20.245Z info hostd[AA40B70] [Originator@6876 sub=Vimsvc.ha-eventmgr] Event 2417 : Device or filesystem with identifier naa.60014055c425cd10a874374b415629b3 has entered the All Paths Down state.  
2018-07-05T21:16:38.337Z info hostd[9F40B70] [Originator@6876 sub=Vimsvc.ha-eventmgr] Event 2437 : Device or filesystem with identifier naa.60014055c425cd10a874374b415629b3 has exited the All Paths Down state.
```

## ssh 接続
auth.log で接続元 IP とかで検索すれば。それか実行したコマンド。
```bat
2018-07-05T20:12:46Z sshd[77731]: Connection from 172.31.255.6 port 50311
2018-07-05T20:12:46Z sshd[77731]: User 'root' running command 'vim-cmd vmsvc/power.getstate 91 2>&1'
2018-07-05T20:12:46Z sshd[77731]: Disconnected from 172.31.255.6 port 50311
```
