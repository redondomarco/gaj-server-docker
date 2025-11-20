#!/bin/bash
cd /gaj-server-main/src/
/usr/bin/mvn clean package install
cp /gaj-server-main/src/tmf-main-project/tmf-service/target/tmf.war /root/