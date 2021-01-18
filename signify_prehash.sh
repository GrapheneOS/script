#!/bin/bash

set -o errexit -o nounset -o pipefail

source "$(dirname ${BASH_SOURCE[0]})/common.sh"

[[ $# -eq 2 ]] || user_error "expected 2 arguments (key and file to sign)"

key="$(realpath $1)"
file=$(basename $2)

cd "$(dirname $2)"

if [ "$(grep -E 'debian|ubuntu' /etc/os-release)" ]; then
   sha256sum --tag "$file" | signify-openbsd -S -s "$key" -e -m - -x "$file.sig"
else
   sha256sum --tag "$file" | signify -S -s "$key" -e -m - -x "$file.sig"
fi
