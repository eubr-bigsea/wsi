#!/bin/bash

# Copyright 2017 <Marco Lattuada>

abs_script=`readlink -e $0`
dir_script=`dirname $abs_script`


SCRIPT_FILE_1=/insertFakeProfile.sql
SCRIPT_FILE_2=/insertFakeData.sql
SCRIPT_FILE_3=/PREDICTOR_CACHE_TABLE.sql
SCRIPT_FILE_4=/OPTIMIZER_CONFIGURATION_TABLE.sql

DB_IP=${DB_IP:-127.0.0.1}
MYSQL_USER=bigsea
DB_PORT=${DB_PORT:-3306}
MYSQL_DATABASE=bigsea
MYSQL_PASSWORD=${MYSQL_PASSWORD:-b1g534}

if test -d insert_temp; then
   rm -r insert_temp;
fi
mkdir insert_temp

mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -h ${DB_IP} -P ${DB_PORT} ${MYSQL_DATABASE} < ${dir_script}/Database/insertFakeProfile.sql

mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -h ${DB_IP} -P ${DB_PORT} ${MYSQL_DATABASE} < ${dir_script}/Database/insertFakeData.sql

echo "Inserted data for OPT_IC"

wget https://raw.githubusercontent.com/eubr-bigsea/opt_jr/master/PREDICTOR_CACHE_TABLE.sql -P insert_temp
mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -h ${DB_IP} -P ${DB_PORT} ${MYSQL_DATABASE} < insert_temp/PREDICTOR_CACHE_TABLE.sql

wget https://raw.githubusercontent.com/eubr-bigsea/opt_jr/master/OPTIMIZER_CONFIGURATION_TABLE.sql -P insert_temp
mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -h ${DB_IP} -P ${DB_PORT} ${MYSQL_DATABASE} < insert_temp/OPTIMIZER_CONFIGURATION_TABLE.sql

echo "Inserted data for OPT_JR"
