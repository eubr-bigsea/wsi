#!/bin/bash
MYSQL_USER=bigsea
WS_IP=${WS_IP:-127.0.0.1}
WS_PORT=${WS_PORT:-10003}


echo "Testing insertion of new application in running application"
application_session_id=`curl http://${WS_IP}:${WS_PORT}/WSI/session/new`
echo "Application session id is ${application_session_id}"
curl  -H "Content-Type: text/plain" --data "${application_session_id} query55 1000 1485907200000 1.0 100000 4" http://${WS_IP}:${WS_PORT}/WSI_DB/WSDB/register/newapp
curl  -H "Content-Type: text/plain" --data "${application_session_id} 1485907300000" http://${WS_IP}:${WS_PORT}/WSI_DB/WSDB/register/endapp

