#!/usr/bin/env bash

set -eu -o pipefail

gas_meter_reading=$(cat /etc/gas-meter/gas_counter.txt)
gas_meter_id=$(cat /etc/gas-meter/id)

echo "# HELP home_meter_reading Current meter reading in qm"
echo "# Type home_meter_reading counter"
echo "home_meter_reading{meter_type=\"gas\", meter_id=\"$gas_meter_id\", month=\"$(date +%b)\", year=\"$(date +%Y)\"} $gas_meter_reading"
