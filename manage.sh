#!/bin/bash

set -o errexit -o nounset -o pipefail

source "$(dirname ${BASH_SOURCE[0]})/common.sh"

DELETE_TAG=

build_number=
if [[ $# -eq 1 ]]; then
    build_number=$1
elif [[ $# -ne 0 ]]; then
    user_error "expected 0 or 1 arguments"
fi

aosp_forks=(
    device_common
    device_generic_goldfish
    device_google_bonito
    device_google_bonito-sepolicy
    device_google_bramble
    device_google_coral
    device_google_coral-sepolicy
    device_google_crosshatch
    device_google_crosshatch-sepolicy
    device_google_redbull
    device_google_redbull-sepolicy
    device_google_redfin
    device_google_sunfish
    device_google_sunfish-sepolicy
    kernel_configs
    platform_art
    platform_bionic
    platform_bootable_recovery
    platform_build
    platform_build_soong
    platform_development
    platform_external_conscrypt
    #platform_external_sqlite
    #platform_frameworks_av
    platform_frameworks_base
    platform_frameworks_ex
    platform_frameworks_native
    platform_frameworks_opt_net_wifi
    platform_hardware_google_pixel
    platform_libcore
    platform_manifest
    platform_packages_apps_Bluetooth
    platform_packages_apps_Calendar
    platform_packages_apps_Camera2
    platform_packages_apps_Contacts
    platform_packages_apps_DeskClock
    platform_packages_apps_Dialer
    platform_packages_apps_Gallery2
    platform_packages_apps_Launcher3
    platform_packages_apps_Nfc
    platform_packages_apps_PackageInstaller
    platform_packages_apps_QuickSearchBox
    platform_packages_apps_Settings
    platform_packages_apps_SettingsIntelligence
    platform_packages_apps_ThemePicker
    platform_packages_apps_WallpaperPicker2
    platform_packages_inputmethods_LatinIME
    platform_packages_modules_NetworkStack
    platform_packages_providers_DownloadProvider
    platform_packages_services_Telephony
    platform_prebuilts_build-tools
    platform_system_bt
    platform_system_core
    platform_system_extras
    #platform_system_netd
    platform_system_sepolicy
)

declare -A kernels=(
    [google_crosshatch]=android-11.0.0_r0.91 # July 2021
    [google_crosshatch_drivers_staging_qcacld-3.0]=android-11.0.0_r0.91 # July 2021
    [google_crosshatch_techpack_audio]=android-11.0.0_r0.91 # July 2021
    [google_coral]=android-11.0.0_r0.93 # July 2021
    [google_coral_drivers_staging_qcacld-3.0]=android-11.0.0_r0.93 # July 2021
    [google_coral_techpack_audio]=android-11.0.0_r0.93 # July 2021
    [google_sunfish]=android-11.0.0_r0.94 # July 2021
    [google_sunfish_drivers_staging_qcacld-3.0]=android-11.0.0_r0.94 # July 2021
    [google_sunfish_techpack_audio]=android-11.0.0_r0.94 # July 2021
    [google_redbull]=android-11.0.0_r0.95 # July 2021
    [google_redbull_drivers_staging_qca-wifi-host-cmn]=android-11.0.0_r0.95 # July 2021
    [google_redbull_drivers_staging_qcacld-3.0]=android-11.0.0_r0.95 # July 2021
    [google_redbull_techpack_audio]=android-11.0.0_r0.95 # July 2021
    [google_redbull_arch_arm64_boot_dts_vendor]=android-11.0.0_r0.95 # July 2021
)

independent=(
    android-prepare-vendor
    branding
    device_google_blueline-kernel
    device_google_bonito-kernel
    device_google_bramble-kernel
    device_google_coral-kernel
    device_google_crosshatch-kernel
    device_google_redfin-kernel
    device_google_sunfish-kernel
    hardened_malloc
    kernel_prebuilts_build-tools
    platform_external_Auditor
    platform_external_PdfViewer
    platform_external_vanadium
    platform_external_talkback
    platform_packages_apps_ExactCalculator
    platform_packages_apps_SetupWizard
    platform_packages_apps_Updater
    platform_themes
    script
    Vanadium
)

for repo in "${aosp_forks[@]}"; do
    echo -e "\n>>> $(tput setaf 3)Handling $repo$(tput sgr0)"

    cd $repo

    git checkout $branch

    if [[ -n $DELETE_TAG ]]; then
        git tag -d $DELETE_TAG
        git push origin :refs/tags/$DELETE_TAG
        cd ..
        continue
    fi

    if [[ -n $build_number ]]; then
        if [[ $repo == platform_manifest ]]; then
            git checkout -B tmp
            sed -i s%refs/heads/$branch%refs/tags/$aosp_version.$build_number% default.xml
            git commit default.xml -m $aosp_version.$build_number
        fi

        if [[ $repo != platform_manifest ]]; then
            git tag -s $aosp_version.$build_number -m $aosp_version.$build_number
            git push origin $aosp_version.$build_number
        else
            git push -fu origin tmp
        fi

        if [[ $repo == platform_manifest ]]; then
            git checkout $branch
            git branch -D tmp
        fi
    else
        git fetch upstream --tags

        git pull --rebase upstream $aosp_tag
        git push -f
    fi

    cd ..
done

for kernel in ${!kernels[@]}; do
    echo -e "\n>>> $(tput setaf 3)Handling kernel_$kernel$(tput sgr0)"

    cd kernel_$kernel
    git checkout $branch

    if [[ -n $DELETE_TAG ]]; then
        git tag -d $DELETE_TAG
        git push origin :refs/tags/$DELETE_TAG
        cd ..
        continue
    fi

    if [[ -n $build_number ]]; then
        git tag -s $aosp_version.$build_number -m $aosp_version.$build_number
        git push origin $aosp_version.$build_number
    else
        git fetch upstream --tags
        kernel_tag=${kernels[$kernel]}
        if [[ -z $kernel_tag ]]; then
            cd ..
            continue
        fi

        git checkout $branch
        git rebase $kernel_tag
        git push -f
    fi

    cd ..
done

for repo in ${independent[@]}; do
    echo -e "\n>>> $(tput setaf 3)Handling $repo$(tput sgr0)"

    cd $repo
    git checkout $branch

    if [[ -n $DELETE_TAG ]]; then
        git tag -d $DELETE_TAG
        git push origin :refs/tags/$DELETE_TAG
        cd ..
        continue
    fi

    if [[ -n $build_number ]]; then
        git tag -s $aosp_version.$build_number -m $aosp_version.$build_number
        git push origin $aosp_version.$build_number
    else
        git push -f
    fi

    cd ..
done
