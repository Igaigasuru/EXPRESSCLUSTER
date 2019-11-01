# html の書き方サンプル
## コマンドを実行し、実行結果を表示する（例：ホスト名）
```bat
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Test Web</title>
</head>
<body>
	<div class="wrapper">
		<script>
			var wsh = new ActiveXObject("WScript.Shell");
			var nameexec = wsh.Exec("hostname");
			var nameget = nameexec.StdOut.ReadAll();
			document.write("<div>You are connecting to: " + nameget + "</div>");
		</script>
	</div>
</body>
</html>
```
clpstat も行けるけど、改行が html だと空白になるので、表示するとき要注意。
