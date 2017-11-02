#!/bin/bash

# Copyright 2017 <Marco Lattuada>

abs_script=`readlink -e $0`
dir_script=`dirname $abs_script`


SCRIPT_FILE_1=/insertFakeProfile.sql
SCRIPT_FILE_2=/insertFakeData.sql
SCRIPT_FILE_3=/PREDICTOR_CACHE_TABLE.sql
SCRIPT_FILE_4=/OPTIMIZER_CONFIGURATION_TABLE.sql
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
docker cp ${dir_script}/Database/insertFakeProfile.sql ${DOCKER_DB_CONTAINER_NAME}:${SCRIPT_FILE_1}
docker exec ${DOCKER_DB_CONTAINER_NAME} bin/bash -c "mysql -u${MYSQL_USER} -p${user_db_password} ${MYSQL_DATABASE} < ${SCRIPT_FILE_1}";
docker cp ${dir_script}/Database/insertFakeData.sql ${DOCKER_DB_CONTAINER_NAME}:${SCRIPT_FILE_2}
docker exec ${DOCKER_DB_CONTAINER_NAME} bin/bash -c "mysql -u${MYSQL_USER} -p${user_db_password} ${MYSQL_DATABASE} < ${SCRIPT_FILE_2}";
echo "Inserted data for OPT_IC"

#Inserting data for OPT_JR
docker cp ${DOCKER_WS_CONTAINER_NAME}:/tarball/opt_jr/PREDICTOR_CACHE_TABLE.sql PREDICTOR_CACHE_TABLE.sql
docker cp PREDICTOR_CACHE_TABLE.sql ${DOCKER_DB_CONTAINER_NAME}:${SCRIPT_FILE_3}
rm PREDICTOR_CACHE_TABLE.sql
docker exec ${DOCKER_DB_CONTAINER_NAME} bin/bash -c "mysql -u${MYSQL_USER} -p${user_db_password} ${MYSQL_DATABASE} < ${SCRIPT_FILE_3}";


docker cp ${DOCKER_WS_CONTAINER_NAME}:/tarball/opt_jr/OPTIMIZER_CONFIGURATION_TABLE.sql OPTIMIZER_CONFIGURATION_TABLE.sql
docker cp OPTIMIZER_CONFIGURATION_TABLE.sql ${DOCKER_DB_CONTAINER_NAME}:${SCRIPT_FILE_4}
rm OPTIMIZER_CONFIGURATION_TABLE.sql
docker exec ${DOCKER_DB_CONTAINER_NAME} bin/bash -c "mysql -u${MYSQL_USER} -p${user_db_password} ${MYSQL_DATABASE} < ${SCRIPT_FILE_4}";
echo "Inserted data for OPT_JR"
echo "Done"
