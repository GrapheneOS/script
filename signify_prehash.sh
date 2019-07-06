#!/bin/bash

[[ $# -eq 2 ]] || exit 1

sha256sum --tag $2 | signify -S -s $1 -e -m - -x $2.sig
