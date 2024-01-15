#!/bin/sh

wget https://mirrors.cloud.tencent.com/gradle/gradle-8.5-bin.zip
sudo mkdir /opt/gradle
sudo unzip -d /opt/gradle gradle-8.5-bin.zip
echo 'export PATH="$PATH":/opt/gradle/gradle-8.5/bin' >> ~/.bashrc
source ~/.bashrc
gradle -v
