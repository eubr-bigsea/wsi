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
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-b1g534}
MYSQL_USER=${MYSQL_USER:-bigsea}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-b1g534}
WSI_SERVICE_PORT=${WSI_SERVICE_PORT:-8080}

DIR_TEMP=ws_docker_temp

function create_database {

    MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} MYSQL_USER=${MYSQL_USER} MYSQL_PASSWORD=${MYSQL_PASSWORD} ${SCRIPT_CREATE_DB}

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
    if test -d ws_docker_temp; then
       rm -r ws_docker_temp;
    fi
    mkdir ws_docker_temp
    echo "Configuration..."
    sed "s/<entry key=\"AppsPropDB_pass\">.*<\/entry>/<entry key=\"AppsPropDB_pass\">${MYSQL_PASSWORD}<\/entry>/g; s/<entry key=\"OptDB_pass\">.*<\/entry>/<entry key=\"OptDB_pass\">${MYSQL_PASSWORD}<\/entry>/g" ${WSI_HOME}/docker/wsi_config.xml > ${DIR_TEMP}/wsi_config.xml
    cp ${WSI_HOME}/docker/Dockerfile ${DIR_TEMP}/Dockerfile

    echo "Build docker image for services..."
    docker build --no-cache --force-rm -t wsi ${DIR_TEMP}
    echo "Delete temporary directory"
    rm -rf ws_docker_temp
    echo "Launch container"
    # TODO
    docker run --name wsi_service -d -p ${WSI_SERVICE_PORT}:8080 wsi
    return 0
}

delete_database && \
create_database && \
delete_services && \
build_services
