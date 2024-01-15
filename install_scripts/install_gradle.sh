#!/bin/sh

version=7.6
# version=8.5
wget https://mirrors.cloud.tencent.com/gradle/gradle-$version-bin.zip
sudo mkdir /opt/gradle
sudo unzip -d /opt/gradle gradle-$version-bin.zip
echo "export PATH=\"$PATH\":/opt/gradle/gradle-$version/bin" >> ~/.bashrc
source ~/.bashrc
gradle -v
