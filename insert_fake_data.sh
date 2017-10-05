#!/bin/bash

# Copyright 2017 <Marco Lattuada>

abs_script=`readlink -e $0`
dir_script=`dirname $abs_script`


SCRIPT_FILE_1=/insertFakeData.sql
SCRIPT_FILE_2=/PREDICTOR_CACHE_TABLE.sql
MYSQL_USER=bigsea
DOCKER_DB_CONTAINER_NAME=mysql_bigsea
DOCKER_WS_CONTAINER_NAME=wsi_service
DOCKER_MYSQL_PORT=3306
MYSQL_DATABASE=bigsea

echo "Insertion Fake Data into Docker container: ${DOCKER_DB_CONTAINER_NAME}"
grep_command="grep OptDB_pass wsi_config.xml"
password_line=`docker exec ${DOCKER_WS_CONTAINER_NAME} /bin/bash -c "${grep_command}"`
user_db_password=`echo $password_line | awk -F\> {'print $2'} | awk -F\< {'print $1'}`


#Inserting data for OPT_IC
docker cp ${dir_script}/Database/insertFakeData.sql ${DOCKER_DB_CONTAINER_NAME}:${SCRIPT_FILE_1}
docker exec ${DOCKER_DB_CONTAINER_NAME} bin/bash -c "mysql -u${MYSQL_USER} -p${user_db_password} ${MYSQL_DATABASE} < ${SCRIPT_FILE_1}";

#Inserting data for OPT_JR
docker cp ${DOCKER_WS_CONTAINER_NAME}:/tarball/opt_jr/PREDICTOR_CACHE_TABLE.sql PREDICTOR_CACHE_TABLE.sql
docker cp PREDICTOR_CACHE_TABLE.sql ${DOCKER_DB_CONTAINER_NAME}:${SCRIPT_FILE_2}
rm PREDICTOR_CACHE_TABLE.sql
docker exec ${DOCKER_DB_CONTAINER_NAME} bin/bash -c "mysql -u${MYSQL_USER} -p${user_db_password} ${MYSQL_DATABASE} < ${SCRIPT_FILE_2}";
echo "Done"
