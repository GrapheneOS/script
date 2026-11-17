#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

(( $# == 3 )) || user_error "expected 3 arguments (device, source and target version)"

chrt -b -p 0 $$

PERSISTENT_KEY_DIR=keys/$1
DEVICE=$1
OLD=$2
NEW=$3

# decrypt keys in advance for improved performance and modern algorithm support
KEY_DIR=$(mktemp -d /dev/shm/generate-delta.XXXXXXXXXX)
trap 'rm -rf "${KEY_DIR}"' EXIT
cp "$PERSISTENT_KEY_DIR"/* "$KEY_DIR"
script/decrypt-keys "$KEY_DIR"

export PATH="$PWD/prebuilts/build-tools/linux-x86/bin:$PATH"
export PATH="$PWD/prebuilts/build-tools/path/linux-x86:$PATH"
export PATH="$PWD/releases/$NEW/release-$DEVICE-$NEW/bin:$PATH"

cd "releases/$NEW"
OTA_ARGS=()
if [[ $DEVICE == @(rango|mustang|blazer|frankel) ]]; then
    OTA_ARGS=( --disable_ublk )
fi

DEV_ZIP="$DEVICE-target_files.zip"
OLD_DEV_ZIP="../$OLD/release-$DEVICE-$OLD/$DEV_ZIP"
REL_DEV_ZIP="release-$DEVICE-$NEW/$DEV_ZIP"
INC_DEV_ZIP="$DEVICE-incremental-$OLD-$NEW.zip"

ota_from_target_files -k "$KEY_DIR/releasekey" "${OTA_ARGS[@]}" \
    -i "$OLD_DEV_ZIP" \
    "$REL_DEV_ZIP" \
    "$INC_DEV_ZIP"
