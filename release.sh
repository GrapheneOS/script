#!/bin/bash

set -o pipefail

source "$(dirname ${BASH_SOURCE[0]})/common.sh"

chrt -b -p 0 $$

[[ $# -eq 1 ]] || user_error "expected a single argument (device type)"
[[ -n $BUILD_NUMBER ]] || user_error "expected BUILD_NUMBER in the environment"

PERSISTENT_KEY_DIR=keys/$1
RELEASE_OUT=out/release-$1-$BUILD_NUMBER

# decrypt keys in advance for improved performance and modern algorithm support
KEY_DIR=$(mktemp -d /dev/shm/release_keys.XXXXXXXXXX) || exit 1
trap "rm -rf \"$KEY_DIR\"" EXIT
cp "$PERSISTENT_KEY_DIR"/* "$KEY_DIR" || exit 1
script/decrypt_keys.sh "$KEY_DIR" || exit 1

OLD_PATH="$PATH"
export PATH="$PWD/prebuilts/build-tools/linux-x86/bin:$PATH"
export PATH="$PWD/prebuilts/build-tools/path/linux-x86:$PATH"

rm -rf $RELEASE_OUT || exit 1
mkdir -p $RELEASE_OUT || exit 1
unzip $OUT/otatools.zip -d $RELEASE_OUT/otatools || exit 1

source $RELEASE_OUT/otatools/device/common/clear-factory-images-variables.sh || exit 1

get_radio_image() {
    grep "require version-$1" vendor/$2/vendor-board-info.txt | cut -d '=' -f 2 | tr '[:upper:]' '[:lower:]' || exit 1
}

if [[ $1 == crosshatch || $1 == blueline || $1 == bonito || $1 == sargo || $1 == coral || $1 == flame || $1 == sunfish || $1 == bramble || $1 == redfin ]]; then
    BOOTLOADER=$(get_radio_image bootloader google_devices/$1)
    RADIO=$(get_radio_image baseband google_devices/$1)
    PREFIX=aosp_
elif [[ $1 != hikey && $1 != hikey960 ]]; then
    user_error "$1 is not supported by the release script"
fi

BUILD=$BUILD_NUMBER
VERSION=$BUILD_NUMBER
DEVICE=$1
PRODUCT=$1

TARGET_FILES=$DEVICE-target_files-$BUILD.zip

if [[ $DEVICE != hikey* ]]; then
    AVB_PKMD="$KEY_DIR/avb_pkmd.bin"
    AVB_ALGORITHM=SHA256_RSA4096
    [[ $(stat -c %s "$KEY_DIR/avb_pkmd.bin") -eq 520 ]] && AVB_ALGORITHM=SHA256_RSA2048

    if [[ $DEVICE == blueline || $DEVICE == crosshatch || $1 == bonito || $1 == sargo ]]; then
        VERITY_SWITCHES=(--avb_vbmeta_key "$KEY_DIR/avb.pem" --avb_vbmeta_algorithm $AVB_ALGORITHM
                         --avb_system_key "$KEY_DIR/avb.pem" --avb_system_algorithm $AVB_ALGORITHM)
        EXTRA_OTA=(--retrofit_dynamic_partitions)
    else
        VERITY_SWITCHES=(--avb_vbmeta_key "$KEY_DIR/avb.pem" --avb_vbmeta_algorithm $AVB_ALGORITHM
                         --avb_system_key "$KEY_DIR/avb.pem" --avb_system_algorithm $AVB_ALGORITHM)
    fi
fi

$RELEASE_OUT/otatools/releasetools/sign_target_files_apks -o -d "$KEY_DIR" "${VERITY_SWITCHES[@]}" \
    out/target/product/$DEVICE/obj/PACKAGING/target_files_intermediates/$PREFIX$DEVICE-target_files-$BUILD_NUMBER.zip \
    $RELEASE_OUT/$TARGET_FILES || exit 1

if [[ $DEVICE != hikey* ]]; then
    $RELEASE_OUT/otatools/releasetools/ota_from_target_files -k "$KEY_DIR/releasekey" \
        "${EXTRA_OTA[@]}" $RELEASE_OUT/$TARGET_FILES \
        $RELEASE_OUT/$DEVICE-ota_update-$BUILD.zip || exit 1
    script/generate_metadata.py $RELEASE_OUT/$DEVICE-ota_update-$BUILD.zip "$KEY_DIR/releasekey.pk8" || exit 1
fi

$RELEASE_OUT/otatools/releasetools/img_from_target_files $RELEASE_OUT/$TARGET_FILES \
    $RELEASE_OUT/$DEVICE-img-$BUILD.zip || exit 1

cd $RELEASE_OUT || exit 1

if [[ $DEVICE == hikey* ]]; then
    source otatools/device/linaro/hikey/factory-images/generate-factory-images-$DEVICE.sh || exit 1
else
    source otatools/device/common/generate-factory-images-common.sh || exit 1
fi

cd ../..

if [[ -f "$KEY_DIR/factory.sec" ]]; then
    export PATH="$OLD_PATH"
    script/signify_prehash.sh "$KEY_DIR/factory.sec" $RELEASE_OUT/$DEVICE-factory-$BUILD_NUMBER.zip || exit 1
fi
