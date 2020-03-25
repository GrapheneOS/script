#!/bin/bash

set -o errexit -o pipefail

source "$(dirname ${BASH_SOURCE[0]})/common.sh"

[[ $# -eq 3 ]] || user_error "expected 3 arguments (device, source and target version)"

PERSISTENT_KEY_DIR=keys/$1
DEVICE=$1
OLD=$2
NEW=$3

# decrypt keys in advance for improved performance and modern algorithm support
KEY_DIR=$(mktemp -d --tmpdir delta_keys.XXXXXXXXXX)
trap "rm -rf \"$KEY_DIR\"" EXIT
cp "$PERSISTENT_KEY_DIR"/* "$KEY_DIR"
script/decrypt_keys.sh "$KEY_DIR"

./build/tools/releasetools/ota_from_target_files --block "${EXTRA_OTA[@]}" -k "$KEY_DIR/releasekey" \
    -i releases/$OLD/release-$DEVICE-$OLD/$DEVICE-target_files-$OLD.zip \
    releases/$NEW/release-$DEVICE-$NEW/$DEVICE-target_files-$NEW.zip \
    releases/$NEW/$DEVICE-incremental-$OLD-$NEW.zip
