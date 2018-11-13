### awk
```bat
clpstat | awk -F: '{print $1}'
```
":" で区切った 1 番目のブロックを表示する。  
複数行あるときは各行でそれぞれ処理する

### sed
```bat
clpstat | grep failover | awk -F: '{print $1}' | sed "s/ //g"
```
" " (半角スペース) を "" (なにもなし) に置換＝スペース一括削除

```bat
clpstat | sed -n '2,5p'
```
2 行目から 5 行目まで抽出して表示。  
'2p' だと 2 行目以降表示になる。p を d にすると 2 - 5 行目を削除して表示かも。

### cut
```bat
clpstat | grep failover | cut -c 2-
```
2 文字目から表示（1文字目削除）

### grep
```bat
clpstat | grep -n current
```
行数を表示して grep

### while
```bat
clpstat | while read line
do
    echo $line
    :
    exit 1
done
echo $? 
```
1 行ずつ読み込んで変数 line に格納される
do - done の間の処理は子プロセスとして実行されるから、break ではなく exit。
このときの戻り値が while の実行結果になるから $? で取り出し可能。（上記の通りだと exit 1 するので echo $? で 1 が表示される。）

### date
```bat
date +"%y/%m/%d %H:%M:%S
```
ログと同じタイムスタンプ表記
