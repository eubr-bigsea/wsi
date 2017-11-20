#!/bin/bash
MYSQL_USER=bigsea
MYSQL_DATABASE=bigsea

grep_command="grep DB_pass wsi_config.xml"
MYSQL_PASSWORD=${MYSQL_PASSWORD:-b1g534}
WS_IP=${WS_IP:-127.0.0.1}
DB_IP=${DB_IP:-127.0.0.1}
WS_PORT=${WS_PORT:-10003}
DB_PORT=${DB_PORT:-10057}

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


mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -h${DB_IP} -P${DB_PORT} ${MYSQL_DATABASE} < temp_sql_command.sql
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

curl http://${WS_IP}:${WS_PORT}/bigsea/rest/ws/resopt/${application_ID}/${dataset_size}/${first_deadline}
curl http://${WS_IP}:${WS_PORT}/bigsea/rest/ws/resopt/${application_ID}/${dataset_size}/${second_deadline}
curl http://${WS_IP}:${WS_PORT}/bigsea/rest/ws/resopt/${application_ID}/${dataset_size}/${third_deadline}

sleep ${sleep_time}

mysql_command="DELETE FROM OPTIMIZER_CONFIGURATION_TABLE where application_id = \"${application_ID}\" AND dataset_size = ${dataset_size} AND deadline = ${execution_time_first_configuration};"
echo ${mysql_command} | mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -h${DB_IP} -P${DB_PORT} ${MYSQL_DATABASE}
mysql_command="DELETE FROM OPTIMIZER_CONFIGURATION_TABLE where application_id = \"${application_ID}\" AND dataset_size = ${dataset_size} AND deadline = ${execution_time_second_configuration};"
echo ${mysql_command} | mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -h${DB_IP} -P${DB_PORT} ${MYSQL_DATABASE}
echo "Finished insertion of new data"
