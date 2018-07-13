# ESXi Commands memo for me
ESXiのネットワーク設定確認に使ったコマンドめも。

### esxcfg-route -l
送信ポート設定一覧表示

### esxcfg-route -n
neighbor 宛ての送信ポート表示  
https://orebibou.com/2014/06/vmware-esxi%E3%81%AE%E3%82%B3%E3%83%9E%E3%83%B3%E3%83%89%E3%83%AA%E3%83%95%E3%82%A1%E3%83%AC%E3%83%B3%E3%82%B9-esxcfg-route/

### tcpdump-w -i vmkX
tcpdump。dst/src host オプションとか使えなければ | grep でがんばる？  
https://kb.vmware.com/s/article/1031186?lang=ja

### esxcli network ip interface ipv4 get
ifconfig

### esxcli network ip neighbor
arp -a

### esxcfg-vswitch <vSwitch名> -L/-U <物理NIC名(vmnic_xxxxx)>
仮想スイッチと物理 NIC の紐づけ。 -L→紐づける　-U→紐づけ解除
