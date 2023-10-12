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

rm -rf delta-generation
mkdir delta-generation
export TMPDIR="$PWD/delta-generation"

parallel --use-cores-instead-of-threads -q script/generate_delta.sh ::: sunfish coral flame ::: $@ ::: $SOURCE
rmdir delta-generation
