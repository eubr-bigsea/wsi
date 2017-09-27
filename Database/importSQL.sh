#!/bin/bash
# Copyright 2017 <Biagio Festa>

SCRIPT_FILE=/creationDB.sql
/bin/bash -c "mysql -u$1 -p$2 $3 < ${SCRIPT_FILE}";

