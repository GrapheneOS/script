#!/bin/bash

set -o errexit -o nounset -o pipefail

source "$(dirname ${BASH_SOURCE[0]})/common.sh"

[[ $# -ge 2 ]] || user_error "expected 2 or more arguments (target and source versions)"

read -p "Enter key passphrase (empty if none): " -s password
echo
export password

chrt -b -p 0 $$

SOURCE=$1
shift

export TMPDIR="${OUT:-$PWD/delta-generation}"

parallel -j4 -q script/generate_delta.sh ::: husky shiba felix tangorpro lynx cheetah panther bluejay raven oriole barbet ::: $@ ::: $SOURCE
