#!/bin/bash

set -o pipefail

source "$(dirname ${BASH_SOURCE[0]})/common.sh"

chrt -b -p 0 $$

[[ $# -eq 3 ]] || user_error "expected 3 arguments (device type) (zip path) (output zip path)"

PERSISTENT_KEY_DIR=keys/$1
IN_ZIP_LOCATION=$2
OUT_ZIP_LOCATION=$3

# decrypt keys in advance for improved performance and modern algorithm support
KEY_DIR=$(mktemp -d /dev/shm/release_keys.XXXXXXXXXX) || exit 1
trap "rm -rf \"$KEY_DIR\"" EXIT
cp "$PERSISTENT_KEY_DIR"/* "$KEY_DIR" || exit 1
script/decrypt_keys.sh "$KEY_DIR" || exit 1

export PATH="$PWD/prebuilts/build-tools/linux-x86/bin:$PATH"
export PATH="$PWD/prebuilts/build-tools/path/linux-x86:$PATH"

java -Djava.library.path="prebuilts/sdk/tools/linux/lib64" -jar prebuilts/sdk/tools/lib/signapk.jar -w $KEY_DIR/releasekey.x509.pem $KEY_DIR/releasekey.pk8 $IN_ZIP_LOCATION $OUT_ZIP_LOCATION

