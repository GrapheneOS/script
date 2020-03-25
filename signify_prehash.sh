#!/bin/bash

set -o errexit -o pipefail

source "$(dirname ${BASH_SOURCE[0]})/common.sh"

[[ $# -eq 2 ]] || user_error "expected 2 arguments (key and file to sign)"

key="$(realpath $1)"
file=$(basename $2)

cd "$(dirname $2)"
sha256sum --tag "$file" | signify -S -s "$key" -e -m - -x "$file.sig"
