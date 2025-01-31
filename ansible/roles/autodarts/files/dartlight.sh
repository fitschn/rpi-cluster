#!/bin/bash

HUE_BASE_ADDR="hue.fritz.box"

CMD="$1" # start / stop
DEV="$2" # device name as it is configured in your hue app

HUE_USER_ID=$(cat "$CREDENTIALS_DIRECTORY/hue_user_id")

# Get ID of hue device
HUE_LIGHT_ID=$(curl -s -X GET -k "https://$HUE_BASE_ADDR/api/$HUE_USER_ID/lights" | \
                 jq -r 'to_entries[] | select(.value.name=="Dartbeleuchtung") | .key')

# start / stop light
case $CMD in
  start)
    if curl -s -X PUT -H "Content-Type: application/json" -d '{"on":true}' -k \
      "https://$HUE_BASE_ADDR/api/$HUE_USER_ID/lights/$HUE_LIGHT_ID/state" | grep success; then
      exit 0
    else
      echo "Error occured. Wasn't able to turn on the light $DEV"
      exit 1
    fi
  ;;

  stop)
    if curl -s -X PUT -H "Content-Type: application/json" -d '{"on":false}' -k \
      "https://$HUE_BASE_ADDR/api/$HUE_USER_ID/lights/$HUE_LIGHT_ID/state" | grep success; then
      exit 0
    else
      echo "Error occured. Wasn't able to turn off the light $DEV"
      exit 1
    fi
  ;;

  *)
    echo "Unknown parameter. Only start|stop is allowed"
    exit 1
  ;;
esac
