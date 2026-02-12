#!/bin/bash

set -o errexit -o nounset -o pipefail

source "$(dirname ${BASH_SOURCE[0]})/common.sh"

[[ $# -eq 0 ]] || user_error "expected no arguments"
[[ -n $TARGET_PRODUCT ]] || user_error "expected TARGET_PRODUCT in the environment"
[[ -n $BUILD_NUMBER ]] || user_error "expected BUILD_NUMBER in the environment"
[[ -n $OUT ]] || user_error "expected OUT in the environment"

readonly releases=releases/$BUILD_NUMBER
mkdir -p $releases
otatools="${ANDROID_HOST_OUT}/obj/ETC/otatools-packagelinux_glibc_x86_64_intermediates/otatools-packagelinux_glibc_x86_64"
cp "${otatools}" "$releases/$TARGET_PRODUCT-otatools.zip"
cp "$OUT/obj/PACKAGING/target_files_intermediates/$TARGET_PRODUCT-target_files.zip" "$releases/"
