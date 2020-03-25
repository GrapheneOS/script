#!/bin/bash

set -o errexit -o pipefail

user_error() {
    echo $1 >&2
    exit 1
}

[[ $# -eq 2 ]] || user_error "expected 2 arguments (target and source version)"

for device in bonito sargo crosshatch blueline taimen walleye; do
    for old in $2; do
        script/generate_delta.sh $device $old $1
    done
done
