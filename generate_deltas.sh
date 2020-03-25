#!/bin/bash

set -o errexit -o pipefail

[[ $# -eq 2 ]] || exit 1

for device in bonito sargo crosshatch blueline taimen walleye; do
    for old in $2; do
        script/generate_delta.sh $device $old $1
    done
done
