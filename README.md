# singularity_guacamole
## singularity image のビルド
以下のコマンドで singularity image をビルドしてください。
```
$ sudo singularity build guacamole.sif Singularity
```
## 初期設定
以下のコマンドで singularity isntance 起動のための初期設定を行います。
```
$ perl init.pl 
tomcatのSHUTDOWNポート番号を入力してください: 58005
tomcatのポート番号を入力してください: 58080
server.xmlを生成しました。
guacamole serverのポート番号を入力してください: 54822
guacamole_home/guacamole.propertiesを出力しました。
guacamoleのログインユーザー名を入力してください: okuda
guacamoleのログインパスワードを入力してください: 
guacamole_home/user-mapping.xmlを出力しました。
start_container.shを出力しました。
```
以下のファイルが生成されます。
- server.xml
- guacamole_home/guacamole.properties
- guacamole_home/user-mapping.xml
- tomcat_logs/
- start_container.sh

## guacamole の接続先の設定
guacamole_home/user-mapping.xml に接続先情報を追加してください。

## singularity instance の起動
以下のコマンドで singularity instance を起動します。
```
$ bash start_container.sh
INFO:    instance started successfully
guacd[15]: INFO:	Guacamole proxy daemon (guacd) version 1.3.0 started
Using CATALINA_BASE:   /opt/tomcat
Using CATALINA_HOME:   /opt/tomcat
Using CATALINA_TMPDIR: /opt/tomcat/temp
Using JRE_HOME:        /usr
Using CLASSPATH:       /opt/tomcat/bin/bootstrap.jar:/opt/tomcat/bin/tomcat-juli.jar
Using CATALINA_OPTS:   
Tomcat started.
```
## guacamole へのアクセス
http://localhost:<tomcatのポート番号>/guacamole をウェブブラウザで開いてください。
