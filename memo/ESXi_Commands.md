# ESXi Commands memo for me
ESXiのネットワーク設定確認に使ったコマンドめも。

### esxcfg-route -l
送信ポート設定一覧表示

### esxcfg-route -n
neighbor 宛ての送信ポート表示  
https://orebibou.com/2014/06/vmware-esxi%E3%81%AE%E3%82%B3%E3%83%9E%E3%83%B3%E3%83%89%E3%83%AA%E3%83%95%E3%82%A1%E3%83%AC%E3%83%B3%E3%82%B9-esxcfg-route/

### tcpdump-uw -i vmkX host \<IP Address\>
tcpdump。-e 付けると MAC アドレス表示になる。  
https://kb.vmware.com/s/article/1031186?lang=ja

### esxcli network ip interface ipv4 get
ifconfig

### esxcli network ip neighbor
arp -a
esxcffg-route -n でもいい。

### esxcfg-vswitch <vSwitch名> -L/-U <物理NIC名(vmnic_xxxxx)>
仮想スイッチと物理 NIC の紐づけ。 -L→紐づける　-U→紐づけ解除

### esxcli storage vmfs extent list
デバイス名とパーティション番号の確認

### voma -m vmfs -f \[check | fix\] -d /vmfs/devices/disks/<デバイス名:パーティション番号>
vmfs メタデータの整合性確認/修復

### pktcap-uw --switchport \<switch port\> -o \<output file path\>
仮想スイッチ回りのパケットキャプチャ。
switchport は net-stats -l コマンドで確認可能。
アウトプットは /vmfs 配下が消えなくていいかも。キャプチャファイルは SCP で取り出して WireShark とかで確認。
仮想スイッチ回り以外もキャプチャできる：
http://noaboutsnote.hatenablog.com/entry/pktcap-uw_usage
