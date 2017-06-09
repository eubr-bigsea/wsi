#!/bin/bash

WSI_IP="localhost"
WSI_PORT="8080"
APP_IDS=("application_1483347394756_0" \
             "application_1483347394756_1" \
             "application_1483347394756_2")
NUM_CORES=$(( (RANDOM % 1001) + 1))

# Open new session
echo "Open a new session..."
SID=$(curl "http://${WSI_IP}:${WSI_PORT}/WSI/session/new")
echo "Session ID ${SID}"

# Set the number of calls
NUMCALLS=${#APP_IDS[@]}
echo "Setting ${NUMCALLS} calls and ${NUM_CORES} cores"
curl -X POST "http://${WSI_IP}:${WSI_PORT}/WSI/session/setcalls?SID=${SID}&ncalls=${NUMCALLS}&ncores=${NUM_CORES}"
echo ""

# Set app param for each app
for app in ${APP_IDS[@]}; do
    echo "Setting application: ${app}";
    curl -X POST -H "Content-Type: text/plain" -d "${app} 3.14 3.14" "http://${WSI_IP}:${WSI_PORT}/WSI/session/setparams?SID=${SID}"
    echo ""
done;
