#!/bin/bash

# This wrapper is intended only for writing the actual metrics files that can be collected by
# the text file collector. The actual script to generate the metrics can output the results to
# stdout and does not have to worry about file handling.

set -o pipefail

while getopts i:a:o: flag
do
    case "${flag}" in
        i) input_script=${OPTARG};;
        a) input_script_args=${OPTARG};;
        o) output_file=${OPTARG};;
        *) echo "Invalid argument" && exit 1
    esac
done

# Check if input file is provided and exists
if [ ! -f "$input_script" ]; then
    echo "Provided input file doesn't exist or -i parameter is missing."
    exit 1
fi

# Check if output file is provided
if [ -z "$output_file" ]; then
    echo "You have to provide an output file via -o parameter, e.g.:"
    echo "$0 -o /tmp/my-output.prom"
    exit 1
fi

# Check if directory of output file exists
tcDir="/opt/node-exporter/textfile-collector/"
if [ ! -d ${tcDir} ]; then
    echo "Directory for the output file doesn't exist"
    exit 1
fi

metrics=$($input_script "$input_script_args")
rc=$?

if [[ ${rc} -ne 0 ]]; then
    echo "" > "${tcDir}${output_file}"
else
    echo "$metrics" > "${tcDir}${output_file}"
fi

exit ${rc}
