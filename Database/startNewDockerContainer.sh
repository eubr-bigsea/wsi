#!/bin/bash
# Copyright 2017 <Biagio Festa>

MYSQL_ROOT_PASSWORD=admin
MYSQL_USER=user
MYSQL_USER_PASSWORD=user
MYSQL_DATABASE=bigsea

DOCKER_CONTAINER_NAME=mysql_bigsea
DOCKER_MYSQL_PORT=3306

# Debug purpose
# set -xe

function until_conn {
    echo "Wait for connection... (this operation will take about 15 seconds)";
    until sudo docker exec -it mysql_bigsea mysqladmin ping -uroot -p${MYSQL_ROOT_PASSWORD} > /dev/null;
    do
        sleep 1;
    done
    sleep 10;
    return 0;
}

docker rm -f ${DOCKER_CONTAINER_NAME} && \
    docker run -d --name ${DOCKER_CONTAINER_NAME} -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
           -e MYSQL_DATABASE=${MYSQL_DATABASE} -p ${DOCKER_MYSQL_PORT}:3306 mysql:latest && \
    until_conn && \
    docker cp creationDB.sql ${DOCKER_CONTAINER_NAME}:/ && \
    docker cp insertFakeData.sql ${DOCKER_CONTAINER_NAME}:/ && \
    docker cp importSQL.sh ${DOCKER_CONTAINER_NAME}:/ && \
    docker exec -it ${DOCKER_CONTAINER_NAME} chmod u+x /importSQL.sh && \
    docker exec -it ${DOCKER_CONTAINER_NAME} mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "create user '${MYSQL_USER}'@'%' identified by '${MYSQL_USER_PASSWORD}';" && \
    docker exec -it ${DOCKER_CONTAINER_NAME} mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "grant all on ${MYSQL_DATABASE}.* to '${MYSQL_USER}'@'%';" && \
    docker exec -it ${DOCKER_CONTAINER_NAME} /importSQL.sh root ${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE}
