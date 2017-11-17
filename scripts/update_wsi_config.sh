#!/bin/bash
if [ ! -z ${DB_ADDRESS} ]; then
    sed -i "s/<entry key=\"DB_IP\">.*<\/entry>/<entry key=\"DB_IP\">${DB_ADDRESS}<\/entry>/g;" /home/wsi/wsi_config.xml
fi
if [ ! -z ${DB_PORT} ]; then
    sed -i "s/<entry key=\"DB_port\">.*<\/entry>/<entry key=\"DB_port\">${DB_PORT}<\/entry>/g;" /home/wsi/wsi_config.xml
fi
