#!/bin/bash

user_error() {
  echo user error, please replace user and try again >&2
  exit 1
}

[[ $# -eq 1 ]] || user_error
[[ -n $BUILD_NUMBER ]] || user_error

KEY_DIR=keys/$1
OUT=out/release-$1-$BUILD_NUMBER

source device/common/clear-factory-images-variables.sh

get_radio_image() {
  grep -Po "require version-$1=\K.+" vendor/$2/vendor-board-info.txt | tr '[:upper:]' '[:lower:]'
}

if [[ $1 == taimen || $1 == walleye || $1 == crosshatch || $1 == blueline || $1 == bonito || $1 == sargo ]]; then
  BOOTLOADER=$(get_radio_image bootloader google_devices/$1)
  RADIO=$(get_radio_image baseband google_devices/$1)
  PREFIX=aosp_
elif [[ $1 == hikey || $1 == hikey960 ]]; then
  :
else
  user_error
fi

BUILD=$BUILD_NUMBER
VERSION=$(grep -Po "BUILD_ID=\K.+" build/core/build_id.mk | tr '[:upper:]' '[:lower:]')
DEVICE=$1
PRODUCT=$1

mkdir -p $OUT || exit 1

TARGET_FILES=$DEVICE-target_files-$BUILD.zip

if [[ $DEVICE != hikey* ]]; then
  if [[ $DEVICE == blueline || $DEVICE == crosshatch || $1 == bonito || $1 == sargo ]]; then
    VERITY_SWITCHES=(--avb_vbmeta_key "$KEY_DIR/avb.pem" --avb_vbmeta_algorithm SHA256_RSA2048
                     --avb_system_key "$KEY_DIR/avb.pem" --avb_system_algorithm SHA256_RSA2048)
    AVB_PKMD="$PWD/$KEY_DIR/avb_pkmd.bin"
    EXTRA_OTA=(--retrofit_dynamic_partitions)
  else
    VERITY_SWITCHES=(--avb_vbmeta_key "$KEY_DIR/avb.pem" --avb_vbmeta_algorithm SHA256_RSA2048)
    AVB_PKMD="$PWD/$KEY_DIR/avb_pkmd.bin"
  fi
fi

build/tools/releasetools/sign_target_files_apks -o -d "$KEY_DIR" \
  -k "build/target/product/security/networkstack=$KEY_DIR/networkstack" "${VERITY_SWITCHES[@]}" \
  out/target/product/$DEVICE/obj/PACKAGING/target_files_intermediates/$PREFIX$DEVICE-target_files-$BUILD_NUMBER.zip \
  $OUT/$TARGET_FILES || exit 1

if [[ $DEVICE != hikey* ]]; then
  build/tools/releasetools/ota_from_target_files --block -k "$KEY_DIR/releasekey" \
    "${EXTRA_OTA[@]}" $OUT/$TARGET_FILES \
    $OUT/$DEVICE-ota_update-$BUILD.zip || exit 1
  script/generate_metadata.py $OUT/$DEVICE-ota_update-$BUILD.zip
fi

build/tools/releasetools/img_from_target_files $OUT/$TARGET_FILES \
  $OUT/$DEVICE-img-$BUILD.zip || exit 1

cd $OUT || exit 1

if [[ $DEVICE == hikey* ]]; then
  source ../../device/linaro/hikey/factory-images/generate-factory-images-$DEVICE.sh
else
  source ../../device/common/generate-factory-images-common.sh
fi

mv $DEVICE-$VERSION-factory-*.zip $DEVICE-factory-$BUILD_NUMBER.zip

cd ../..

if [[ -f $KEY_DIR/../factory.sec ]]; then
    script/signify_prehash.sh $KEY_DIR/../factory.sec $OUT/$DEVICE-factory-$BUILD_NUMBER.zip
fi
