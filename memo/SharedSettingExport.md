# 共有/アクセス設定のエキスポート/インポート
CLP/ECX アンインストールするけど cifs の共有設定残したいときに使える。

## 手順
- 1 号機で cifs 活性
- 1 号機で設定エキスポート  
	```bat
	PS> Get-SmbShare | Export-Clixml -Path C:\backupsmb_cifsact.xml
	```
- 2 号機にグループ移動
- 2 号機で設定エキスポート
- CLP/ECX アンインストール
- 1 号機 / 2 号機でインポート  
	```bat
	PS> Import-Clixml -Path C:\backupsmb_cifsact.xml | New-SmbShare
	```
  
## メモ
- 設定確認
	- PS> Get-SmbShare
	- PS> Get-SmbShareAccess
- md 活性/非活性すると共有設定消えるから、md 削除してデバイス見えてからインポート

## 参考
https://qiita.com/speaktech/items/078f1ae37b1f6174ede2
