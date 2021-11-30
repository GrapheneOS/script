#!/bin/bash

set -o pipefail

source "$(dirname ${BASH_SOURCE[0]})/common.sh"

[[ $# -eq 1 ]] || user_error "expected a single argument (device type)"
[[ -n $BUILD_NUMBER ]] || user_error "expected BUILD_NUMBER in the environment"

chrt -b -p 0 $$

PERSISTENT_KEY_DIR=keys/$1
RELEASE_OUT=out/release-$1-$BUILD_NUMBER

# decrypt keys in advance for improved performance and modern algorithm support
KEY_DIR=$(mktemp -d /dev/shm/release_keys.XXXXXXXXXX) || exit 1
trap "rm -rf \"$KEY_DIR\" && rm -f \"$PWD/$RELEASE_OUT/keys\"" EXIT
cp "$PERSISTENT_KEY_DIR"/* "$KEY_DIR" || exit 1
script/decrypt_keys.sh "$KEY_DIR" || exit 1

OLD_PATH="$PATH"
export PATH="$PWD/prebuilts/build-tools/linux-x86/bin:$PATH"
export PATH="$PWD/prebuilts/build-tools/path/linux-x86:$PATH"

rm -rf $RELEASE_OUT || exit 1
mkdir -p $RELEASE_OUT || exit 1
unzip $OUT/otatools.zip -d $RELEASE_OUT || exit 1
cd $RELEASE_OUT

# reproducible key path for otacerts.zip
ln -s "$KEY_DIR" keys || exit 1
KEY_DIR=keys

export PATH="$PWD/bin:$PATH"

source device/common/clear-factory-images-variables.sh || exit 1

BUILD=$BUILD_NUMBER
VERSION=$BUILD_NUMBER
DEVICE=$1
PRODUCT=$DEVICE

get_radio_image() {
    grep "require version-$1" $ANDROID_BUILD_TOP/vendor/$2/vendor-board-info.txt | cut -d '=' -f 2 | tr '[:upper:]' '[:lower:]' || exit 1
}

if [[ $DEVICE == @(crosshatch|blueline|bonito|sargo|coral|flame|sunfish|bramble|redfin|barbet) ]]; then
    BOOTLOADER=$(get_radio_image bootloader google_devices/$DEVICE)
    RADIO=$(get_radio_image baseband google_devices/$DEVICE)
    DISABLE_UART=true
else
    user_error "$DEVICE is not supported by the release script"
fi

TARGET_FILES=$DEVICE-target_files-$BUILD.zip

AVB_PKMD="$KEY_DIR/avb_pkmd.bin"
AVB_ALGORITHM=SHA256_RSA4096
[[ $(stat -c %s "$KEY_DIR/avb_pkmd.bin") -eq 520 ]] && AVB_ALGORITHM=SHA256_RSA2048

if [[ $DEVICE == @(blueline|crosshatch|bonito|sargo) ]]; then
    EXTRA_OTA=(--retrofit_dynamic_partitions)
fi

sign_target_files_apks -o -d "$KEY_DIR" --avb_vbmeta_key "$KEY_DIR/avb.pem" --avb_vbmeta_algorithm $AVB_ALGORITHM \
    --extra_apks OsuLogin.apk,ServiceConnectivityResources.apk,ServiceWifiResources.apk="$KEY_DIR/releasekey" \
    --extra_apks com.android.adbd.apex="$KEY_DIR/releasekey" \
    --extra_apex_payload_key com.android.adbd.apex="$KEY_DIR/avb.pem" \
    --extra_apks com.android.apex.cts.shim.apex="$KEY_DIR/releasekey" \
    --extra_apex_payload_key com.android.apex.cts.shim.apex="$KEY_DIR/avb.pem" \
    --extra_apks com.android.appsearch.apex="$KEY_DIR/releasekey" \
    --extra_apex_payload_key com.android.appsearch.apex="$KEY_DIR/avb.pem" \
    --extra_apks com.android.art.apex="$KEY_DIR/releasekey" \
    --extra_apex_payload_key com.android.art.apex="$KEY_DIR/avb.pem" \
    --extra_apks com.android.cellbroadcast.apex="$KEY_DIR/releasekey" \
    --extra_apex_payload_key com.android.cellbroadcast.apex="$KEY_DIR/avb.pem" \
    --extra_apks com.android.conscrypt.apex="$KEY_DIR/releasekey" \
    --extra_apex_payload_key com.android.conscrypt.apex="$KEY_DIR/avb.pem" \
    --extra_apks com.android.extservices.apex="$KEY_DIR/releasekey" \
    --extra_apex_payload_key com.android.extservices.apex="$KEY_DIR/avb.pem" \
    --extra_apks com.android.i18n.apex="$KEY_DIR/releasekey" \
    --extra_apex_payload_key com.android.i18n.apex="$KEY_DIR/avb.pem" \
    --extra_apks com.android.ipsec.apex="$KEY_DIR/releasekey" \
    --extra_apex_payload_key com.android.ipsec.apex="$KEY_DIR/avb.pem" \
    --extra_apks com.android.media.apex="$KEY_DIR/releasekey" \
    --extra_apex_payload_key com.android.media.apex="$KEY_DIR/avb.pem" \
    --extra_apks com.android.media.swcodec.apex="$KEY_DIR/releasekey" \
    --extra_apex_payload_key com.android.media.swcodec.apex="$KEY_DIR/avb.pem" \
    --extra_apks com.android.mediaprovider.apex="$KEY_DIR/releasekey" \
    --extra_apex_payload_key com.android.mediaprovider.apex="$KEY_DIR/avb.pem" \
    --extra_apks com.android.neuralnetworks.apex="$KEY_DIR/releasekey" \
    --extra_apex_payload_key com.android.neuralnetworks.apex="$KEY_DIR/avb.pem" \
    --extra_apks com.android.os.statsd.apex="$KEY_DIR/releasekey" \
    --extra_apex_payload_key com.android.os.statsd.apex="$KEY_DIR/avb.pem" \
    --extra_apks com.android.permission.apex="$KEY_DIR/releasekey" \
    --extra_apex_payload_key com.android.permission.apex="$KEY_DIR/avb.pem" \
    --extra_apks com.android.resolv.apex="$KEY_DIR/releasekey" \
    --extra_apex_payload_key com.android.resolv.apex="$KEY_DIR/avb.pem" \
    --extra_apks com.android.runtime.apex="$KEY_DIR/releasekey" \
    --extra_apex_payload_key com.android.runtime.apex="$KEY_DIR/avb.pem" \
    --extra_apks com.android.scheduling.apex="$KEY_DIR/releasekey" \
    --extra_apex_payload_key com.android.scheduling.apex="$KEY_DIR/avb.pem" \
    --extra_apks com.android.sdkext.apex="$KEY_DIR/releasekey" \
    --extra_apex_payload_key com.android.sdkext.apex="$KEY_DIR/avb.pem" \
    --extra_apks com.android.tethering.apex="$KEY_DIR/releasekey" \
    --extra_apex_payload_key com.android.tethering.apex="$KEY_DIR/avb.pem" \
    --extra_apks com.android.tzdata.apex="$KEY_DIR/releasekey" \
    --extra_apex_payload_key com.android.tzdata.apex="$KEY_DIR/avb.pem" \
    --extra_apks com.android.vndk.current.apex="$KEY_DIR/releasekey" \
    --extra_apex_payload_key com.android.vndk.current.apex="$KEY_DIR/avb.pem" \
    --extra_apks com.android.wifi.apex="$KEY_DIR/releasekey" \
    --extra_apex_payload_key com.android.wifi.apex="$KEY_DIR/avb.pem" \
    --extra_apks com.google.pixel.camera.hal.apex="$KEY_DIR/releasekey" \
    --extra_apex_payload_key com.google.pixel.camera.hal.apex="$KEY_DIR/avb.pem" \
    "$OUT/obj/PACKAGING/target_files_intermediates/$TARGET_FILES" $TARGET_FILES || exit 1

ota_from_target_files -k "$KEY_DIR/releasekey" "${EXTRA_OTA[@]}" $TARGET_FILES \
    $DEVICE-ota_update-$BUILD.zip || exit 1
script/generate_metadata.py $DEVICE-ota_update-$BUILD.zip || exit 1

img_from_target_files $TARGET_FILES $DEVICE-img-$BUILD.zip || exit 1

source device/common/generate-factory-images-common.sh || exit 1

if [[ -f "$KEY_DIR/factory.sec" ]]; then
    export PATH="$OLD_PATH"
    script/signify_prehash.sh "$KEY_DIR/factory.sec" $DEVICE-factory-$BUILD_NUMBER.zip || exit 1
fi
