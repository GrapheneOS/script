#!/bin/bash

set -o errexit -o nounset -o pipefail

source "$(dirname ${BASH_SOURCE[0]})/common.sh"

read -p "Enter key passphrase (empty if none): " -s password
export password

chrt -b -p 0 $$

[[ $# -ge 2 ]] || user_error "expected 2 or more arguments (target and source versions)"
SOURCE=$1
shift

for device in redfin bramble sunfish coral flame bonito sargo crosshatch blueline; do
    for old in $@; do
        script/generate_delta.sh $device $old $SOURCE
    done
done
