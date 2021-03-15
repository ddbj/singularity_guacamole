Bootstrap: docker
From: ubuntu:18.04

%environment
    export GUACAMOLE_HOME=/etc/guacamole
%post
    sed -i.bak -e "s%http://archive.ubuntu.com/ubuntu/%http://ftp.jaist.ac.jp/pub/Linux/ubuntu/%g" /etc/apt/sources.list
    sed -i.bak -e "s%http://security.ubuntu.com/ubuntu/%http://ftp.jaist.ac.jp/pub/Linux/ubuntu/%g" /etc/apt/sources.list
    apt-get -y update
    apt-get -y upgrade
    apt-get -y install vim wget sudo less

    apt-get -y install gcc g++ software-properties-common libcairo2-dev libjpeg-turbo8-dev libpng-dev libtool-bin libossp-uuid-dev libavutil-dev libswscale-dev build-essential libssh2-1-dev libssl-dev libpango1.0-dev libvncserver-dev libtelnet-dev libpulse-dev libwebp-dev libogg-dev libvorbis-dev libvorbisenc2 libwebp-dev 
    add-apt-repository ppa:remmina-ppa-team/freerdp-daily
    apt-get -y update
    apt-get -y install freerdp2-dev freerdp2-x11 
    apt-get -y install openjdk-11-jdk unzip

    # install guacamole server

    cd /usr/local/src
    wget http://archive.apache.org/dist/guacamole/1.3.0/source/guacamole-server-1.3.0.tar.gz
    tar xzvf guacamole-server-1.3.0.tar.gz
    cd guacamole-server-1.3.0
    ./configure
    make
    make install
    echo /usr/local/lib > /etc/ld.so.conf.d/custom.conf
    ldconfig
    mkdir /etc/guacamole

    # install tomcat

    cd /usr/local/src
    export TOMCAT_VERSION="9.0.44"
    wget https://ftp.kddi-research.jp/infosystems/apache/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz
    tar xzvf apache-tomcat-${TOMCAT_VERSION}.tar.gz
    mv apache-tomcat-${TOMCAT_VERSION} /opt/tomcat
    rm -r /opt/tomcat/webapps/*

    # install guacamole.war

    cd /usr/local/src
    wget http://archive.apache.org/dist/guacamole/1.3.0/binary/guacamole-1.3.0.war
    cp guacamole-1.3.0.war /opt/tomcat/webapps/guacamole.war
    /opt/tomcat/bin/startup.sh
    sleep 10
    /opt/tomcat/bin/shutdown.sh

    chmod 755 /opt/tomcat/bin
    chmod 755 /opt/tomcat/bin/*
    chmod 755 /opt/tomcat/conf
    chmod 644 /opt/tomcat/conf/*
    chmod 755 /opt/tomcat/lib
    chmod 644 /opt/tomcat/lib/*
    chmod 755 /opt/tomcat/webapps
    chmod 755 -R /opt/tomcat/webapps/guacamole

