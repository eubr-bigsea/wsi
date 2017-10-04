#!/bin/bash
# Copyright 2017 <Biagio Festa>
# Bash script insert fake debugging test 

SCRIPT_FILE=/insertFakeData.sql
MYSQL_USER=bigsea
DOCKER_CONTAINER_NAME=mysql_bigsea
DOCKER_MYSQL_PORT=3306
MYSQL_DATABASE=bigsea

echo "Insertion Fake Data into Docker container: ${DOCKER_CONTAINER_NAME}"
echo -n "User Password: "
read -s user_db_password

docker exec -it ${DOCKER_CONTAINER_NAME} bin/bash -c "mysql -u${MYSQL_USER} -p${user_db_password} ${MYSQL_DATABASE} < ${SCRIPT_FILE}";
echo "Done"

