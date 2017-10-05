#!/bin/bash
# Copyright 2017 <Biagio Festa>

# Put in $DIR the path of the script
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
echo $DIR

MYSQL_ROOT_PASSWORD=4dm1n
MYSQL_USER=bigsea
MYSQL_USER_PASSWORD=b1g534
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

docker run -d --name ${DOCKER_CONTAINER_NAME} -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
           -e MYSQL_DATABASE=${MYSQL_DATABASE} -p ${DOCKER_MYSQL_PORT}:3306 mysql:latest && \
    until_conn && \
    docker cp ${DIR}/creationDB.sql ${DOCKER_CONTAINER_NAME}:/ && \
    docker cp ${DIR}/importSQL.sh ${DOCKER_CONTAINER_NAME}:/ && \
    docker exec -it ${DOCKER_CONTAINER_NAME} chmod u+x /importSQL.sh && \
    docker exec -it ${DOCKER_CONTAINER_NAME} mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "create user '${MYSQL_USER}'@'%' identified by '${MYSQL_USER_PASSWORD}';" && \
    docker exec -it ${DOCKER_CONTAINER_NAME} mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "grant all on ${MYSQL_DATABASE}.* to '${MYSQL_USER}'@'%';" && \
    docker exec -it ${DOCKER_CONTAINER_NAME} /importSQL.sh root ${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} && \
    echo "Done."
