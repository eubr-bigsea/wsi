#!/bin/bash
# Copyright 2017 <Biagio Festa>

abs_script=`readlink -e $0`
DIR_SCRIPT=`dirname $abs_script`

MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-b1g534}
MYSQL_USER=${MYSQL_USER:-bigsea}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-b1g534}

WSI_SERVICE_PORT=${WSI_SERVICE_PORT:-8080}

DOCKER_CONTAINER_NAME=mysql_bigsea
DOCKER_MYSQL_PORT=3306

# Debug purpose
# set -xe

if test -d db_docker_temp; then
   rm -r db_docker_temp;
fi
mkdir db_docker_temp

docker build --no-cache --rm -t mysql_bigsea_image ${DIR_SCRIPT} --build-arg MYSQL_ROOT_PASSWORD_ARG=${MYSQL_ROOT_PASSWORD} --build-arg MYSQL_USER_ARG=${MYSQL_USER} --build-arg MYSQL_PASSWORD_ARG=${MYSQL_PASSWORD}
docker run --name mysql_bigsea -d -p ${DOCKER_MYSQL_PORT}:3306 mysql_bigsea_image

#rm -r db_docker_temp
