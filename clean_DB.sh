#!/bin/bash

# Copyright 2017 <Marco Lattuada>

abs_script=`readlink -e $0`
dir_script=`dirname $abs_script`

DB_IP=${DB_IP:-127.0.0.1}
MYSQL_USER=bigsea
DB_PORT=${DB_PORT:-3306}
MYSQL_DATABASE=bigsea
MYSQL_PASSWORD=${MYSQL_PASSWORD:-b1g534}

echo "Cleaning DB: mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -h ${DB_IP} -P ${DB_PORT} ${MYSQL_DATABASE} < ${dir_script}/Database/clean_DB.sql"
mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -h ${DB_IP} -P ${DB_PORT} ${MYSQL_DATABASE} < ${dir_script}/Database/clean_DB.sql
