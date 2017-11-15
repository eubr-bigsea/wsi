#!/bin/bash

# Copyright 2017 <Marco Lattuada>

abs_script=`readlink -e $0`
dir_script=`dirname $abs_script`

DOCKER_DB_CONTAINER_NAME=mysql_bigsea

SCRIPT_FILE=/clean_DB.sql
MYSQL_USER=bigsea
DOCKER_WS_CONTAINER_NAME=wsi_service
DOCKER_MYSQL_PORT=3306
MYSQL_DATABASE=bigsea

grep_command="grep DB_pass wsi_config.xml"
password_line=`docker exec ${DOCKER_WS_CONTAINER_NAME} /bin/bash -c "${grep_command}"`
user_db_password=`echo $password_line | awk -F\> {'print $2'} | awk -F\< {'print $1'}`

#Inserting data for OPT_JR
docker cp ${dir_script}/Database/clean_DB.sql ${DOCKER_DB_CONTAINER_NAME}:${SCRIPT_FILE}
docker exec ${DOCKER_DB_CONTAINER_NAME} bin/bash -c "mysql -u${MYSQL_USER} -p${user_db_password} ${MYSQL_DATABASE} < ${SCRIPT_FILE}";
echo "Done"
