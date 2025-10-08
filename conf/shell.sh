#!/bin/bash
dockerid=`docker ps | grep tomcat9java11 | cut -f1 -d' '`
echo id docker $dockerid
docker exec -t -i $dockerid bash
exit 0