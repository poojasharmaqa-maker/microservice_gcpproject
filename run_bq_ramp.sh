#!/bin/sh
export GOOGLE_APPLICATION_CREDENTIALS=/var/secrets/google/key.json
#export DQ_PROPERTY_FILE=$1
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/oracle/instant_client
# export CONNECTION_FILE=/var/secrets/google/drhprd07.properties
python json_subscribe.py --sleep_time=180 --message_pull=5000
