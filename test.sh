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
      if [ "$diff_gt_zero" == "1" ]; then
         diff=`echo "-($diff)" | sed 's/e/*10^/g' |bc`
#         echo "Diff is now $diff"
      fi
      error=`echo "$diff / $golden_element" | sed 's/e/*10^/g' | bc -l`
#      echo "error is $error"
      relevant_error=`echo "$error > 0.001" | sed 's/e/*10^/g' | bc`
#      echo "Relevant error is ${relevant_error}"
      if [ "${relevant_error}" == "1" ]; then
         echo "Result has wrong value in position $index: $golden_element vs. $element. Error is $error"
         exit -1
      fi
   done
}

DOCKER_DB_CONTAINER_NAME=mysql_bigsea
DOCKER_WS_CONTAINER_NAME=wsi_service
MYSQL_USER=bigsea
MYSQL_DATABASE=bigsea
MYSQL_PASSWORD=${MYSQL_PASSWORD:-b1g534}
TIMEOUT=30
WS_IP=${WS_IP:-127.0.0.1}
DB_IP=${DB_IP:-127.0.0.1}
WS_PORT=${WS_PORT:-10003}
DB_PORT=${DB_PORT:-10057}

MYSQL_PASSWORD=${MYSQL_PASSWORD} DB_IP=${DB_IP} DB_PORT=${DB_PORT} ${dir_script}/clean_DB.sh
MYSQL_PASSWORD=${MYSQL_PASSWORD} DB_IP=${DB_IP} DB_PORT=${DB_PORT} ${dir_script}/insert_fake_data.sh

if test -d test_temp; then
   rm -r test_temp;
fi
mkdir test_temp


################################################################################
#                                                                              #
#                                                                              #
#                           Test update running app                            #
#                                                                              #
#                                                                              #
################################################################################
WS_IP=${WS_IP} WS_PORT=${WS_PORT} ${dir_script}/scripts/update_running_application_test.sh




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
echo "${MYSQL_PASSWORD}" >> test_temp/new_data_example.txt

cat ${dir_script}/test_temp/new_data_example.txt | ${dir_script}/insert_new_data.sh

waited_minutes=0
while :
do
   mysql_command="SELECT num_cores_opt FROM OPTIMIZER_CONFIGURATION_TABLE WHERE application_id = 'query55' AND dataset_size=1000 and deadline=500300"
   result=`echo "${mysql_command}" | mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -h ${DB_IP} -P ${DB_PORT} ${MYSQL_DATABASE} -N | grep -v password`
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

waited_minutes=0
while :
do
   mysql_command="SELECT num_cores_opt FROM OPTIMIZER_CONFIGURATION_TABLE WHERE application_id = 'query55' AND dataset_size=1000 and deadline=650100"
   result=`echo "${mysql_command}" | mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -h ${DB_IP} -P ${DB_PORT} ${MYSQL_DATABASE} -N | grep -v password`
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

waited_minutes=0
while :
do
   mysql_command="SELECT num_cores_opt FROM OPTIMIZER_CONFIGURATION_TABLE WHERE application_id = 'query55' AND dataset_size=1000 and deadline=799900"
   result=`echo "${mysql_command}" | mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -h ${DB_IP} -P ${DB_PORT} ${MYSQL_DATABASE} -N | grep -v password`
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



################################################################################
#                                                                              #
#                                                                              #
#                      Test DAGSim/OPT_IC webservice                           #
#                                                                              #
#                                                                              #
################################################################################

wget https://raw.githubusercontent.com/eubr-bigsea/WS_DagSim/master/ExampleScripts/call_R_dagsim.sh -P test_temp
wget https://raw.githubusercontent.com/eubr-bigsea/WS_DagSim/master/ExampleScripts/call_S_dagsim.sh -P test_temp
wget https://raw.githubusercontent.com/eubr-bigsea/WS_DagSim/master/ExampleScripts/call_dagsim.sh -P test_temp
wget https://raw.githubusercontent.com/eubr-bigsea/WS_DagSim/master/ExampleScripts/call_dagsim_stage.sh -P test_temp
wget https://raw.githubusercontent.com/eubr-bigsea/WS_DagSim/master/ExampleScripts/call_opt_ic.sh -P test_temp
wget https://raw.githubusercontent.com/eubr-bigsea/WS_DagSim/master/ExampleScripts/call_opt_ic_stage.sh -P test_temp
chmod a+x test_temp/*

result=`WS_PORT=${WS_PORT} test_temp/call_R_dagsim.sh` || exit $?
echo "Result of call_R_dagsim is $result"
golden_result="597405"
compare_result || exit $?

result=`WS_PORT=${WS_PORT} test_temp/call_S_dagsim.sh` || exit $?
echo "Result of call_S_dagsim is $result"
golden_result="444221"
compare_result || exit $?

result=`WS_PORT=${WS_PORT} test_temp/call_dagsim.sh` || exit $?
echo "Result of call_dagsim is $result"
golden_result="444221"
compare_result || exit $?

result=`WS_PORT=${WS_PORT} test_temp/call_dagsim_stage.sh` || exit $?
echo "Result of call_dagsim_stage is $result"
golden_result="3213 43349"
compare_result || exit $?

result=`WS_PORT=${WS_PORT} test_temp/call_opt_ic.sh` || exit $?
echo "Result of call_opt_ic.sh is $result"
golden_result="36 5"
compare_result || exit $?

waited_minutes=0
while :
do
   mysql_command="SELECT num_cores_opt FROM OPTIMIZER_CONFIGURATION_TABLE WHERE application_id = 'query26' AND dataset_size=1000 and deadline=400000"
   result=`echo "${mysql_command}" | mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -h ${DB_IP} -P ${DB_PORT} ${MYSQL_DATABASE} -N | grep -v password`
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

result=`WS_PORT=${WS_PORT} test_temp/call_opt_ic_stage.sh`
echo "Result of call_opt_ic_stage.sh is $result"
golden_result="4 1 1686000"
compare_result || exit $?




################################################################################
#                                                                              #
#                                                                              #
#                             Test opt_jr                                      #
#                                                                              #
#                                                                              #
################################################################################

wget https://raw.githubusercontent.com/eubr-bigsea/opt_jr/master/test_opt_jr.sh -P test_temp
chmod ugo+x test_temp/test_opt_jr.sh
wget https://raw.githubusercontent.com/eubr-bigsea/opt_jr/master/execute.sh -P test_temp
chmod ugo+x test_temp/execute.sh
result=`DB_IP=${DB_IP} WS_IP=${WS_IP} WS_PORT=${WS_PORT} DB_PORT=${DB_PORT} test_temp/test_opt_jr.sh | tail -4`
result=`echo $result`
echo "Result of opt_jr is ${result}"
golden_result="68 30 22 30"
compare_result || exit $?

exit 0
