#!/bin/bash

sha256sum --tag $1 | signify -S -s ~/android/grapheneos/keys/factory.sec -e -m - -x $1.sig
