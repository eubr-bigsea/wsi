#!/bin/bash
# Copyright 2017 <Biagio Festa>

# Put in $DIR the path of the script
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
echo $DIR

BASH_BIN=$(which bash)
DOCKER_BIN=$(which docker)
DATABASE_HOME=${DIR}/Database
WSI_HOME=${DIR}//WSI
SCRIPT_CREATE_DB=${DATABASE_HOME}/startNewDockerContainer.sh

function create_database {
    echo "Creation Database"
    echo -n "Root Password: "
    read -s root_db_password
    echo
    echo -n "User Password: "
    read -s user_db_password
    echo
    DIR_TEMP=$(mktemp -d ${DIR}/XXXXX)
    echo "Create temporary directory ${DIR_TEMP}"
    cp -r ${DATABASE_HOME}/* ${DIR_TEMP}
    NAME_TEMP=${DIR_TEMP}/create_db_script.tmp
    cat ${SCRIPT_CREATE_DB} | sed "s|MYSQL_ROOT_PASSWORD=4dm1n|MYSQL_ROOT_PASSWORD=${root_db_password}|g; s|MYSQL_USER_PASSWORD=b1g534|MYSQL_USER_PASSWORD=${user_db_password}|g" > ${NAME_TEMP}
    ${BASH_BIN} ${NAME_TEMP}
    echo "Delete temporaryy directory"
    rm -rf ${DIR_TEMP}
}

function delete_database {
    read -r -p "Do you want to erase previous database installation? [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY])
            docker rm -f mysql_bigsea
            ;;
        *)
            ;;
    esac
}

delete_database
create_database
