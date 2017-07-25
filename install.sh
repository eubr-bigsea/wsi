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
WSI_HOME=${DIR}/WSI
SCRIPT_CREATE_DB=${DATABASE_HOME}/startNewDockerContainer.sh
DB_ADMIN_PASS=
DB_USER_PASS=

function create_database {
    echo "Creation Database"
    echo -n "Root Password: "
    read -s root_db_password
    echo
    echo -n "Repeat Password: "
    read -s root_db_password_2
    echo
    if [ "$root_db_password" != "$root_db_password_2" ];
    then
        echo "Password does not match"
        exit -1
    fi
    DB_ADMIN_PASS=${root_db_password}
    
    echo -n "User Password: "
    read -s user_db_password
    echo
    echo -n "Repeat Password: "
    read -s user_db_password_2
    echo
    if [ "$user_db_password" != "$user_db_password_2" ];
    then
        echo "Password does not match"
        exit -1
    fi
    DB_USER_PASS=${user_db_password}
    
    DIR_TEMP=$(mktemp -d ${DIR}/XXXXX)
    echo "Create temporary directory ${DIR_TEMP}"
    cp -r ${DATABASE_HOME}/* ${DIR_TEMP}
    NAME_TEMP=${DIR_TEMP}/create_db_script.tmp
    cat ${SCRIPT_CREATE_DB} | sed "s|MYSQL_ROOT_PASSWORD=4dm1n|MYSQL_ROOT_PASSWORD=${root_db_password}|g; s|MYSQL_USER_PASSWORD=b1g534|MYSQL_USER_PASSWORD=${user_db_password}|g" > ${NAME_TEMP}
    ${BASH_BIN} ${NAME_TEMP}
    echo "Delete temporary directory"
    rm -rf ${DIR_TEMP}

    return 0
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
    return 0
}

function delete_services {
    read -r -p "Do you want to erase previous services installation? [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY])
            docker rm -f wsi_service
            ;;
        *)
            ;;
    esac
    return 0
}

function build_services {
    DIR_TEMP=$(mktemp -d ${DIR}/XXXXX)
    echo "Create temporary directory ${DIR_TEMP}"
    echo "Configuration..."
    sed "s/<entry key=\"AppsPropDB_pass\">.*<\/entry>/<entry key=\"AppsPropDB_pass\">${DB_USER_PASS}<\/entry>/g; s/<entry key=\"OptDB_pass\">.*<\/entry>/<entry key=\"OptDB_pass\">${DB_USER_PASS}<\/entry>/g" ${WSI_HOME}/docker/wsi_config.xml > ${DIR_TEMP}/wsi_config.xml
    cp ${WSI_HOME}/docker/Dockerfile ${DIR_TEMP}/Dockerfile

    echo "Build docker image for services..."
    docker build --no-cache --force-rm -t wsi ${DIR_TEMP}
    echo "Delete temporary directory"
    rm -rf ${DIR_TEMP}
    echo "Launch container"
    # TODO
    return 0
}

delete_database && \
create_database && \
delete_services && \
build_services
