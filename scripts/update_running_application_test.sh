#!/bin/bash
MYSQL_USER=bigsea
DOCKER_WS_CONTAINER_NAME=wsi_service


echo "Testing insertion of new application in running application"
application_session_id=`docker exec ${DOCKER_WS_CONTAINER_NAME} /bin/bash -c "curl http://localhost:8080/WSI/session/new"`
echo "Application session id is ${application_session_id}"
docker exec ${DOCKER_WS_CONTAINER_NAME} /bin/bash -c "curl  -H \"Content-Type: text/plain\" --data \"${application_session_id} query55 1000 1485907200000 1.0 100000 4\" http://localhost:8080/WSI_DB/WSDB/register/newapp"
docker exec ${DOCKER_WS_CONTAINER_NAME} /bin/bash -c "curl  -H \"Content-Type: text/plain\" --data \"${application_session_id} 1485907300000\" http://localhost:8080/WSI_DB/WSDB/register/endapp"

