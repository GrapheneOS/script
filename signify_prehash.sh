#!/bin/bash

[[ $# -eq 2 ]] || exit 1

key="$(realpath $1)"
file=$(basename $2)

cd "$(dirname $2)"
sha256sum --tag "$file" | signify -S -s "$key" -e -m - -x "$file.sig"
