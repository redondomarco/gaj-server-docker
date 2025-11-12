#!/bin/bash
cd /gaj-server-main/src/
#/usr/bin/mvn -Dspring.profiles.active=local spring-boot:run
/usr/bin/mvn clean package install

cp /gaj-server-main/src/tmf-main-project/tmf-service/target/tmf.war 