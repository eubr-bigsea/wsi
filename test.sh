#!/bin/bash

# Copyright 2017 <Marco Lattuada>

abs_script=`readlink -e $0`
dir_script=`dirname $abs_script`

function compare_result {
   IFS=' ', read -r -a golden_array <<< "$golden_result"
   IFS=' ', read -r -a array <<< "$result"
   if test ${#golden_array[@]} != ${#array[@]}; then
      echo "Result has wrong number of elements"
      exit -1
   fi
   for index in "${!array[@]}"
   do
      golden_element=${golden_array[index]}
      element=${array[index]}
#      echo "Comparing $element with $golden_element"
#      echo "$golden_element - $element" | sed 's/e/*10^/g'
      diff=`echo "$golden_element - $element" | sed 's/e/*10^/g' | bc`
#      echo "Diff is $diff"
      diff_gt_zero=`echo "$diff < 0" | sed 's/e/*10^/g' | bc`
#      echo "Diff is positive: $diff_gt_zero"
      if [ "$diff_git_zero" == "1" ]; then
         diff=`echo "-$diff" | sed 's/e/*10^/g' |bc`
#         echo "Diff is now $diff"
      fi
      error=`echo "$diff / $golden_element" | sed 's/e/*10^/g' | bc`
#      echo "error is $error"
      if [ "$(echo \"$error > 0.001\" | sed 's/e/*10^/g' | bc)" == "1" ]; then
         echo "Result has wrong value in position $index: $golden_element vs. $element. Error is $error"
         exit -1
      fi
   done
}

DOCKER_DB_CONTAINER_NAME=mysql_bigsea
DOCKER_WS_CONTAINER_NAME=wsi_service
MYSQL_USER=bigsea
MYSQL_DATABASE=bigsea
TIMEOUT=30

grep_command="grep OptDB_pass wsi_config.xml"
password_line=`docker exec ${DOCKER_WS_CONTAINER_NAME} /bin/bash -c "${grep_command}"`
user_db_password=`echo $password_line | awk -F\> {'print $2'} | awk -F\< {'print $1'}`

ws_docker_ip=`docker inspect wsi_service |grep \"IPAddress | head -1 | awk '{print $2}' | awk -F'"' '{print $2}'`
db_docker_ip=`docker inspect mysql_bigsea |grep \"IPAddress | head -1 | awk '{print $2}' | awk -F'"' '{print $2}'`

${dir_script}/clean_DB.sh
${dir_script}/insert_fake_data.sh

if test -d test_temp; then
   rm -r test_temp;
fi
mkdir test_temp
docker cp ${DOCKER_WS_CONTAINER_NAME}:/tarball/WS_DagSim/ExampleScripts/call_opt_ic_stage.sh ${dir_script}/test_temp
result=`${dir_script}/test_temp/call_opt_ic_stage.sh`
echo "Result of call_opt_ic_stage.sh is $result"
result=`${dir_script}/test_temp/call_opt_ic_stage.sh`
echo "Result of call_opt_ic_stage.sh is $result"


################################################################################
#                                                                              #
#                                                                              #
#                           Test insert_new_data                               #
#                                                                              #
#                                                                              #
################################################################################
echo "query55" > test_temp/new_data_example.txt
echo "1000" >> test_temp/new_data_example.txt
echo "25" >> test_temp/new_data_example.txt
echo "500200" >> test_temp/new_data_example.txt
echo "10" >> test_temp/new_data_example.txt
echo "800000" >> test_temp/new_data_example.txt
echo "1s" >> test_temp/new_data_example.txt
echo "${user_db_password}" >> test_temp/new_data_example.txt

cat ${dir_script}/test_temp/new_data_example.txt | ${dir_script}/insert_new_data.sh

waited_minutes=0
while :
do
   mysql_command="SELECT num_cores_opt FROM OPTIMIZER_CONFIGURATION_TABLE WHERE application_id = \\\"query55\\\" AND dataset_size=1000 and deadline=500300"
   result=`docker exec ${DOCKER_DB_CONTAINER_NAME} /bin/bash -c "echo \"${mysql_command}\" | mysql -u${MYSQL_USER} -p${user_db_password} ${MYSQL_DATABASE} -N | grep -v password"`
   if [ "$result" == "21" ]; then
      break
   fi
   if [ "$result" != "" ]; then
      echo "Wrong result for query55 - dataset 1000 - deadline 500300: $result"
      exit -1
   fi
   echo "Result is $result"
   sleep 1m
   waited_minute=$(( waited_minute + 1 ))
   if [ "$waited_minutes" -gt "$TIMEOUT" ]; then
      echo "Reached timeout during check of insert_new_application"
      exit -1
   fi
done
echo "Found correct value for application_id query55 - dataset 1000 - deadline 500300: 21"
result=`${dir_script}/test_temp/call_opt_ic_stage.sh`
echo "Result of call_opt_ic_stage.sh is $result"
result=`${dir_script}/test_temp/call_opt_ic_stage.sh`
echo "Result of call_opt_ic_stage.sh is $result"

waited_minutes=0
while :
do
   mysql_command="SELECT num_cores_opt FROM OPTIMIZER_CONFIGURATION_TABLE WHERE application_id = \\\"query55\\\" AND dataset_size=1000 and deadline=650100"
   result=`docker exec ${DOCKER_DB_CONTAINER_NAME} /bin/bash -c "echo \"${mysql_command}\" | mysql -u${MYSQL_USER} -p${user_db_password} ${MYSQL_DATABASE} -N | grep -v password"`
   if [ "$result" == "16" ]; then
      break
   fi
   if [ "$result" != "" ]; then
      echo "Wrong result for query55 - dataset 1000 - deadline 650100: $result"
      exit -1
   fi
   echo "Result is $result"
   sleep 1m
   waited_minute=$(( waited_minute + 1 ))
   if [ "$waited_minutes" -gt "$TIMEOUT" ]; then
      echo "Reached timeout during check of insert_new_application"
      exit -1
   fi
done
echo "Found correct value for application_id query55 - dataset 1000 - deadline 650100: 16"
result=`${dir_script}/test_temp/call_opt_ic_stage.sh`
echo "Result of call_opt_ic_stage.sh is $result"
result=`${dir_script}/test_temp/call_opt_ic_stage.sh`
echo "Result of call_opt_ic_stage.sh is $result"

waited_minutes=0
while :
do
   mysql_command="SELECT num_cores_opt FROM OPTIMIZER_CONFIGURATION_TABLE WHERE application_id = \\\"query55\\\" AND dataset_size=1000 and deadline=799900"
   result=`docker exec ${DOCKER_DB_CONTAINER_NAME} /bin/bash -c "echo \"${mysql_command}\" | mysql -u${MYSQL_USER} -p${user_db_password} ${MYSQL_DATABASE} -N | grep -v password"`
   if [ "$result" == "13" ]; then
      break
   fi
   if [ "$result" != "" ]; then
      echo "Wrong result for query55 - dataset 1000 - deadline 790000: $result"
      exit -1
   fi
   echo "Result is $result"
   sleep 1m
   waited_minute=$(( waited_minute + 1 ))
   if [ "$waited_minutes" -gt "$TIMEOUT" ]; then
      echo "Reached timeout during check of insert_new_application"
      exit -1
   fi
done
echo "Found correct value for application_id query55 - dataset 1000 - deadline 799900: 13"
result=`${dir_script}/test_temp/call_opt_ic_stage.sh`
echo "Result of call_opt_ic_stage.sh is $result"
result=`${dir_script}/test_temp/call_opt_ic_stage.sh`
echo "Result of call_opt_ic_stage.sh is $result"



################################################################################
#                                                                              #
#                                                                              #
#                      Test DAGSim/OPT_IC webservice                           #
#                                                                              #
#                                                                              #
################################################################################

docker cp ${DOCKER_WS_CONTAINER_NAME}:/tarball/WS_DagSim/ExampleScripts/call_R_dagsim.sh ${dir_script}/test_temp
docker cp ${DOCKER_WS_CONTAINER_NAME}:/tarball/WS_DagSim/ExampleScripts/call_S_dagsim.sh ${dir_script}/test_temp
docker cp ${DOCKER_WS_CONTAINER_NAME}:/tarball/WS_DagSim/ExampleScripts/call_dagsim.sh ${dir_script}/test_temp
docker cp ${DOCKER_WS_CONTAINER_NAME}:/tarball/WS_DagSim/ExampleScripts/call_dagsim_stage.sh ${dir_script}/test_temp
docker cp ${DOCKER_WS_CONTAINER_NAME}:/tarball/WS_DagSim/ExampleScripts/call_opt_ic.sh ${dir_script}/test_temp
docker cp ${DOCKER_WS_CONTAINER_NAME}:/tarball/WS_DagSim/ExampleScripts/call_opt_ic_stage.sh ${dir_script}/test_temp
sed -i "s/localhost/${ws_docker_ip}/g" ${dir_script}/test_temp/*
chmod a+x ${dir_script}/test_temp/*

result=`${dir_script}/test_temp/call_R_dagsim.sh`
echo "Result of call_R_dagsim is $result"
golden_result="597405.186 68.45608337878 597400.94304799 597409.42895201 1.4204603862178e-05"
compare_result
result=`${dir_script}/test_temp/call_opt_ic_stage.sh`
echo "Result of call_opt_ic_stage.sh is $result"
result=`${dir_script}/test_temp/call_opt_ic_stage.sh`
echo "Result of call_opt_ic_stage.sh is $result"

result=`${dir_script}/test_temp/call_S_dagsim.sh`
echo "Result of call_S_dagsim is $result"
golden_result="444221.372 71.42999126658 444216.94472327 444225.79927673 1.9932749776369e-05"
compare_result
result=`${dir_script}/test_temp/call_opt_ic_stage.sh`
echo "Result of call_opt_ic_stage.sh is $result"
result=`${dir_script}/test_temp/call_opt_ic_stage.sh`
echo "Result of call_opt_ic_stage.sh is $result"

result=`${dir_script}/test_temp/call_dagsim.sh`
echo "Result of call_dagsim is $result"
golden_result="444221.372 71.42999126658 444216.94472327 444225.79927673 1.9932749776369e-05"
compare_result
result=`${dir_script}/test_temp/call_opt_ic_stage.sh`
echo "Result of call_opt_ic_stage.sh is $result"
result=`${dir_script}/test_temp/call_opt_ic_stage.sh`
echo "Result of call_opt_ic_stage.sh is $result"

result=`${dir_script}/test_temp/call_dagsim_stage.sh`
echo "Result of call_dagsim is_stage $result"
golden_result="3213 22941"
compare_result
result=`${dir_script}/test_temp/call_opt_ic_stage.sh`
echo "Result of call_opt_ic_stage.sh is $result"
result=`${dir_script}/test_temp/call_opt_ic_stage.sh`
echo "Result of call_opt_ic_stage.sh is $result"

result=`${dir_script}/test_temp/call_opt_ic.sh`
echo "Result of call_opt_ic.sh is $result"
golden_result="36 5"
compare_result
result=`${dir_script}/test_temp/call_opt_ic_stage.sh`
echo "Result of call_opt_ic_stage.sh is $result"
result=`${dir_script}/test_temp/call_opt_ic_stage.sh`
echo "Result of call_opt_ic_stage.sh is $result"

result=`${dir_script}/test_temp/call_opt_ic_stage.sh`
echo "Result of call_opt_ic_stage.sh is $result"
golden_result="4 1 2759000"
compare_result
result=`${dir_script}/test_temp/call_opt_ic_stage.sh`
echo "Result of call_opt_ic_stage.sh is $result"

waited_minutes=0
while :
do
   mysql_command="SELECT num_cores_opt FROM OPTIMIZER_CONFIGURATION_TABLE WHERE application_id = \\\"query26\\\" AND dataset_size=1000 and deadline=400000"
   result=`docker exec ${DOCKER_DB_CONTAINER_NAME} /bin/bash -c "echo \"${mysql_command}\" | mysql -u${MYSQL_USER} -p${user_db_password} ${MYSQL_DATABASE} -N | grep -v password"`
   if [ "$result" == "36" ]; then
      break
   fi
   echo "Result is $result"
   sleep 1m
   waited_minute=$(( waited_minute + 1 ))
   if [ "$waited_minutes" -gt "$TIMEOUT" ]; then
      echo "Reached timeout during check of insert_new_application"
      exit -1
   fi
done
echo "Found correct value for application_id query26 - dataset 1000 - deadline 400000: 36"




################################################################################
#                                                                              #
#                                                                              #
#                             Test opt_jr                                      #
#                                                                              #
#                                                                              #
################################################################################

docker cp ${DOCKER_WS_CONTAINER_NAME}:/tarball/opt_jr/test_opt_jr.sh ${dir_script}/test_temp
sed -i "s/localhost/${ws_docker_ip}/g" ${dir_script}/test_temp/test_opt_jr.sh
chmod a+x ${dir_script}/test_temp/test_opt_jr.sh
docker cp ${DOCKER_WS_CONTAINER_NAME}:/tarball/opt_jr/execute.sh ${dir_script}/test_temp
chmod a+x ${dir_script}/test_temp/execute.sh
docker cp ${DOCKER_WS_CONTAINER_NAME}:/home/wsi/wsi_config.xml ${dir_script}/test_temp
result=`FILE=${dir_script}/test_temp/wsi_config.xml DB_IP=${db_docker_ip} WSI_IP=${ws_docker_ip} ${dir_script}/test_temp/test_opt_jr.sh | tail -4`
result=`echo $result`
echo "Result of opt_jr is ${result}"
golden_result="68 30 22 30"
compare_result

exit 0
