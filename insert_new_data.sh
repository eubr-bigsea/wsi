#!/bin/bash
MYSQL_USER=bigsea
DOCKER_DB_CONTAINER_NAME=mysql_bigsea
DOCKER_WS_CONTAINER_NAME=wsi_service
DOCKER_MYSQL_PORT=3306
MYSQL_DATABASE=bigsea

grep_command="grep DB_pass wsi_config.xml"
password_line=`docker exec ${DOCKER_WS_CONTAINER_NAME} /bin/bash -c "${grep_command}"`
user_db_password=`echo $password_line | awk -F\> {'print $2'} | awk -F\< {'print $1'}`

echo "Initialize application data"
echo -n "Application ID: "
read application_ID
echo -n "Dataset size: "
read dataset_size
echo "Insert data about first configuration:"
echo -n "Number of cores: "
read number_of_cores_first_configuration
echo -n "Execution time: "
read execution_time_first_configuration
echo "Insert data about second configuration:"
echo -n "Number of cores: "
read number_of_cores_second_configuration
echo -n "Execution time: "
read execution_time_second_configuration
echo -n "Sleep time to guarantee the ending of three execution of OPT_IC: "
read sleep_time
echo ""

if test -f temp_sql_command.sql; then
   rm temp_sql_command.sql
fi

echo "INSERT INTO \`OPTIMIZER_CONFIGURATION_TABLE\` ( \
\`application_id\`,\
\`dataset_size\`,\
\`deadline\`,\
\`num_cores_opt\`,\
\`num_vm_opt\`)\
   VALUES (\"${application_ID}\", ${dataset_size}, ${execution_time_first_configuration}, ${number_of_cores_first_configuration}, 0), \
   (\"${application_ID}\", ${dataset_size}, ${execution_time_second_configuration}, ${number_of_cores_second_configuration}, 0);" > temp_sql_command.sql

docker cp temp_sql_command.sql  ${DOCKER_DB_CONTAINER_NAME}:/tmp

docker exec ${DOCKER_DB_CONTAINER_NAME} /bin/bash -c "mysql -u${MYSQL_USER} -p${user_db_password} ${MYSQL_DATABASE} < /tmp/temp_sql_command.sql";
rm temp_sql_command.sql

first_deadline=$((execution_time_first_configuration + 100))
second_deadline=$(( (execution_time_first_configuration + execution_time_second_configuration )/ 2))
third_deadline=$((execution_time_second_configuration - 100))
if test "$third_deadline" -lt 0; then
   third_deadline=1
fi

echo "First evaluated deadline is ${first_deadline}"
echo "Second evaluated deadline is ${second_deadline}"
echo "Third evaluated deadline is ${third_deadline}"

docker exec ${DOCKER_WS_CONTAINER_NAME} /bin/bash -c "curl http://localhost:8080/bigsea/rest/ws/resopt/${application_ID}/${dataset_size}/${first_deadline}"
docker exec ${DOCKER_WS_CONTAINER_NAME} /bin/bash -c "curl http://localhost:8080/bigsea/rest/ws/resopt/${application_ID}/${dataset_size}/${second_deadline}"
docker exec ${DOCKER_WS_CONTAINER_NAME} /bin/bash -c "curl http://localhost:8080/bigsea/rest/ws/resopt/${application_ID}/${dataset_size}/${third_deadline}"

sleep ${sleep_time}

mysql_command="DELETE FROM OPTIMIZER_CONFIGURATION_TABLE where application_id = \\\"${application_ID}\\\" AND dataset_size = ${dataset_size} AND deadline = ${execution_time_first_configuration};"
docker exec ${DOCKER_DB_CONTAINER_NAME} /bin/bash -c "echo \"${mysql_command}\" | mysql -u${MYSQL_USER} -p${user_db_password} ${MYSQL_DATABASE}";
mysql_command="DELETE FROM OPTIMIZER_CONFIGURATION_TABLE where application_id = \\\"${application_ID}\\\" AND dataset_size = ${dataset_size} AND deadline = ${execution_time_second_configuration};"
docker exec ${DOCKER_DB_CONTAINER_NAME} /bin/bash -c "echo \"${mysql_command}\" | mysql -u${MYSQL_USER} -p${user_db_password} ${MYSQL_DATABASE}";

