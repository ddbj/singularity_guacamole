#!/usr/bin/perl
use strict;
use warnings;

if (! -e 'guacamole_home') {
    mkdir 'guacamole_home';
}

if (! -e 'tomcat_logs') {
    mkdir 'tomcat_logs';
}

# server.xmlの出力

my $shutdown = &get_port_number("tomcatのSHUTDOWNポート番号");
my $tomcat = &get_port_number("tomcatのポート番号");
my $server_xml = << "SERVER_XML";
<?xml version="1.0" encoding="UTF-8"?>
<Server port="$shutdown" shutdown="SHUTDOWN">
  <Listener className="org.apache.catalina.startup.VersionLoggerListener" />
  <Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" />
  <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />
  <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" />
  <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" />
  <GlobalNamingResources>
    <Resource name="UserDatabase" auth="Container"
              type="org.apache.catalina.UserDatabase"
              description="User database that can be updated and saved"
              factory="org.apache.catalina.users.MemoryUserDatabaseFactory"
              pathname="conf/tomcat-users.xml" />
  </GlobalNamingResources>
  <Service name="Catalina">
    <Connector port="$tomcat" protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="8443" />
    <Engine name="Catalina" defaultHost="localhost">
      <Realm className="org.apache.catalina.realm.LockOutRealm">
        <Realm className="org.apache.catalina.realm.UserDatabaseRealm"
               resourceName="UserDatabase"/>
      </Realm>
      <Host name="localhost"  appBase="webapps"
            unpackWARs="true" autoDeploy="true">
        <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
               prefix="localhost_access_log" suffix=".txt"
               pattern="%h %l %u %t &quot;%r&quot; %s %b" />
      </Host>
    </Engine>
  </Service>
</Server>
SERVER_XML

open OUT, ">server.xml" or die;
print OUT $server_xml;
close OUT;
print "server.xmlを生成しました。\n";

# guacamole.propertiesの出力

my $guacamole = &get_port_number("guacamole serverのポート番号");
my $guacamole_properties = << "GUACAMOLE_PROPERTIES";
guacd-hostname: localhost
guacd-port: $guacamole
user-mapping: /etc/guacamole/user-mapping.xml
auth-provider: net.sourceforge.guacamole.net.basic.BasicFileAuthenticationProvider
GUACAMOLE_PROPERTIES

open OUT, ">guacamole_home/guacamole.properties" or die;
print OUT $guacamole_properties;
close OUT;
print "guacamole_home/guacamole.propertiesを出力しました。\n";

# user-mapping.xmlの出力
print "guacamoleのログインユーザー名を入力してください: ";
my $user_name = <STDIN>;
chomp $user_name;

system "stty -echo";
print "guacamoleのログインパスワードを入力してください: ";
my $password = <STDIN>;
chomp $password;
system "stty echo";
print "\n";
open my $rs, "echo -n $password | openssl md5 2>&1 |";
my @rlist = <$rs>;
close $rs;
my $pw_hash = join '', @rlist;
chomp $pw_hash;
$pw_hash =~ s/.*? //;
my $user_mapping = << "USER_MAPPING";
<user-mapping>
  <authorize
      username="$user_name"
      password="$pw_hash"
      encoding="md5">
  </authorize>
</user-mapping>
USER_MAPPING

open OUT, ">guacamole_home/user-mapping.xml" or die;
print OUT $user_mapping;
close OUT;
print "guacamole_home/user-mapping.xmlを出力しました。\n";

# start_container.shの出力

$user_name =~ s/_/-/g;

my $start_container = << "START_CONTAINER";
#!/bin/bash
CONTAINER_HOME=\$(cd \$(dirname \$0); pwd)
IMAGE="\${CONTAINER_HOME}/guacamole.sif"
INSTANCE="guacamole-${user_name}"
GUACAMOLE_PORT="${guacamole}"

singularity instance start \\
-B \${CONTAINER_HOME}/tomcat_logs:/opt/tomcat/logs \\
-B \${CONTAINER_HOME}/server.xml:/opt/tomcat/conf/server.xml \\
-B \${CONTAINER_HOME}/guacamole_home:/etc/guacamole \\
\${IMAGE} \\
\${INSTANCE}

singularity exec instance://\${INSTANCE} guacd -p /etc/guacamole/guacamole.pid -l \${GUACAMOLE_PORT}
singularity exec instance://\${INSTANCE} /opt/tomcat/bin/startup.sh
START_CONTAINER

open OUT, ">start_container.sh" or die;
print OUT $start_container;
close OUT;
print "start_container.shを出力しました。\n";

sub get_port_number {
    my $label = $_[0];
    my $port_number;
    while (1) {
        print "$labelを入力してください: ";

        $port_number = <STDIN>;
        chomp $port_number;
        if ($port_number =~ /^\d+$/ and $port_number < 65536 and $port_number > 1023) {
            last;
        }
        print "ポート番号が間違っています。\n";
    }
    return $port_number;
}

