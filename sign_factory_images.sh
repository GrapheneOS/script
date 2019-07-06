#!/bin/bash

[[ $# -eq 1 ]] || exit 1

sha256sum --tag $1 | signify -S -s ~/android/grapheneos/keys/factory.sec -e -m - -x $1.sig
