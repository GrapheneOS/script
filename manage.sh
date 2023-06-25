#!/bin/bash

set -o errexit -o nounset -o pipefail

source "$(dirname ${BASH_SOURCE[0]})/common.sh"

[[ $# -eq 0 ]] && user_error "expected action as argument"
readonly action=$1

if [[ $action == @(push|fetch|update) ]]; then
    [[ $# -ne 1 ]] && user_error "expected no arguments for $action"
elif [[ $action == @(release|delete) ]]; then
    readonly tag_name=$2
    [[ $# -ne 2 ]] && user_error "expected tag name as argument for $action"
else
    user_error "unrecognized action"
fi

readonly aosp_forks=(
    device_common
    device_generic_goldfish
    device_google_barbet
    device_google_barbet-sepolicy
    device_google_bluejay
    device_google_bramble
    device_google_coral
    device_google_coral-sepolicy
    device_google_gs-common
    device_google_gs101
    device_google_gs101-sepolicy
    device_google_gs201
    device_google_gs201-sepolicy
    device_google_lynx
    device_google_pantah
    device_google_raviole
    device_google_redbull
    device_google_redbull-sepolicy
    device_google_redfin
    device_google_sunfish
    device_google_sunfish-sepolicy
    device_google_tangorpro
    platform_art
    platform_bionic
    platform_bootable_recovery
    platform_build
    platform_build_soong
    platform_development
    platform_external_android-nn-driver
    platform_external_armnn
    platform_external_boringssl
    platform_external_conscrypt
    platform_external_crosvm
    platform_frameworks_av
    platform_frameworks_base
    platform_frameworks_ex
    platform_frameworks_libs_modules-utils
    platform_frameworks_libs_systemui
    platform_frameworks_native
    platform_frameworks_opt_net_wifi
    platform_frameworks_opt_telephony
    platform_hardware_google_pixel-sepolicy
    platform_libcore
    platform_manifest
    platform_packages_apps_Calendar
    platform_packages_apps_CarrierConfig
    platform_packages_apps_CellBroadcastReceiver
    platform_packages_apps_Contacts
    platform_packages_apps_Dialer
    platform_packages_apps_DocumentsUI
    platform_packages_apps_Gallery2
    platform_packages_apps_Launcher3
    platform_packages_apps_Messaging
    platform_packages_apps_Nfc
    platform_packages_apps_QuickSearchBox
    platform_packages_apps_RemoteProvisioner
    platform_packages_apps_Settings
    platform_packages_apps_SettingsIntelligence
    platform_packages_apps_ThemePicker
    platform_packages_apps_WallpaperPicker2
    platform_packages_inputmethods_LatinIME
    platform_packages_modules_Bluetooth
    platform_packages_modules_common
    platform_packages_modules_Connectivity
    platform_packages_modules_DnsResolver
    platform_packages_modules_NetworkStack
    platform_packages_modules_Permission
    platform_packages_modules_Uwb
    platform_packages_modules_Wifi
    platform_packages_providers_ContactsProvider
    platform_packages_providers_DownloadProvider
    platform_packages_providers_MediaProvider
    platform_packages_services_Telephony
    platform_system_ca-certificates
    platform_system_core
    platform_system_extras
    platform_system_librustutils
    platform_system_sepolicy
    platform_system_timezone
)

readonly kernels=(
    kernel_build-coral
    kernel_msm-coral
    kernel_msm-extra-coral

    kernel_build-redbull
    kernel_msm-redbull
    kernel_msm-modules_qcacld-redbull
    kernel_msm-extra-redbull

    kernel_build-gs
    kernel_gs
    kernel_google-modules_gpu-gs
    kernel_google-modules_wlan_bcmdhd_bcm4389-gs
)

declare -Ar kernel_tags_old=(
    # June 2023
    [kernel_build-coral]=android-13.0.0_r0.80
    [kernel_msm-coral]=android-13.0.0_r0.80
    [kernel_msm-extra-coral]=android-13.0.0_r0.80

    # June 2023
    [kernel_build-redbull]=android-13.0.0_r0.81
    [kernel_msm-redbull]=android-13.0.0_r0.81
    [kernel_msm-modules_qcacld-redbull]=android-13.0.0_r0.81
    [kernel_msm-extra-redbull]=android-13.0.0_r0.81

    # June 2023
    [kernel_build-gs]=android-13.0.0_r0.82
    [kernel_gs]=android-13.0.0_r0.82
    [kernel_google-modules_gpu-gs]=android-13.0.0_r0.82
    [kernel_google-modules_wlan_bcmdhd_bcm4389-gs]=android-13.0.0_r0.82
)

declare -Ar kernel_tags=(
    # June 2023
    [kernel_build-coral]=android-13.0.0_r0.80
    [kernel_msm-coral]=android-13.0.0_r0.80
    [kernel_msm-extra-coral]=android-13.0.0_r0.80

    # June 2023
    [kernel_build-redbull]=android-13.0.0_r0.81
    [kernel_msm-redbull]=android-13.0.0_r0.81
    [kernel_msm-modules_qcacld-redbull]=android-13.0.0_r0.81
    [kernel_msm-extra-redbull]=android-13.0.0_r0.81

    # June 2023
    [kernel_build-gs]=android-13.0.0_r0.82
    [kernel_gs]=android-13.0.0_r0.82
    [kernel_google-modules_gpu-gs]=android-13.0.0_r0.82
    [kernel_google-modules_wlan_bcmdhd_bcm4389-gs]=android-13.0.0_r0.82
)

readonly independent=(
    adevtool
    branding
    carriersettings-extractor
    device_google_bluejay-kernel
    device_google_coral-kernel
    device_google_lynx-kernel
    device_google_pantah-kernel
    device_google_raviole-kernel
    device_google_redbull-kernel
    device_google_sunfish-kernel
    device_google_tangorpro-kernel
    hardened_malloc
    kernel_common-5.10
    kernel_common-5.15
    kernel_manifest-5.10
    kernel_manifest-5.15
    kernel_manifest-bluejay
    kernel_manifest-coral
    kernel_manifest-lynx
    kernel_manifest-pantah
    kernel_manifest-raviole
    kernel_manifest-redbull
    kernel_manifest-tangorpro
    platform_external_Apps
    platform_external_Auditor
    platform_external_Camera
    platform_external_GmsCompatConfig
    platform_external_PdfViewer
    platform_external_seedvault
    platform_external_talkback
    platform_external_vanadium
    platform_packages_apps_DeskClock # temporarily based on AOSP 11 instead of AOSP 13
    platform_packages_apps_ExactCalculator
    platform_packages_apps_GmsCompat
    platform_packages_apps_SetupWizard
    platform_packages_apps_Updater
    platform_themes
    script
    vendor_state
)

for repo in "${aosp_forks[@]}"; do
    echo -e "\n>>> $(tput setaf 3)Handling $repo$(tput sgr0)"

    cd $repo
    git checkout $branch

    if [[ $action == delete ]]; then
        git tag -d $tag_name || true
        git push origin --delete $tag_name || true
    elif [[ $action == release ]]; then
        if [[ $repo == platform_manifest ]]; then
            git checkout -B tmp
            sed -i s%refs/heads/$branch%refs/tags/$tag_name% default.xml
            git commit default.xml -m $tag_name
            git push -fu origin tmp
        else
            git tag -s $tag_name -m $tag_name
            git push origin $tag_name
        fi
    elif [[ $action == update ]]; then
        git fetch upstream --tags
        if [[ $repo != @(platform_build|platform_manifest|device_google_tangorpro) ]]; then
            # reuse base branch when AOSP tags have the same commit
            if [[ $(git rev-list -n 1 $aosp_base_tag) == $(git rev-list -n 1 $aosp_tag) ]]; then
                git checkout $base_branch
            else
                git checkout $aosp_tag
                git cherry-pick $aosp_base_tag..$base_branch
            fi
            git checkout -B $branch
            git push -fu origin $branch
        else
            git rebase --onto $aosp_tag $aosp_tag_old
            git push -f
        fi
    elif [[ $action == push ]]; then
        git push
    elif [[ $action == fetch ]]; then
        git fetch upstream --tags
    fi

    cd ..
done

for repo in ${kernels[@]}; do
    [[ $action != @(release|delete) ]] && continue

    echo -e "\n>>> $(tput setaf 3)Handling $repo$(tput sgr0)"

    cd $repo
    git checkout $base_branch

    if [[ $action == delete ]]; then
        git tag -d $tag_name || true
        git push origin --delete $tag_name || true
    elif [[ $action == release ]]; then
        git tag -s $tag_name -m $tag_name
        git push origin $tag_name
    elif [[ $action == update ]]; then
        git fetch upstream --tags
        git rebase --onto ${kernel_tags[$repo]} ${kernel_tags_old[$repo]}
        git push -f
    elif [[ $action == push ]]; then
        git push
    elif [[ $action == fetch ]]; then
        git fetch upstream --tags
    fi

    cd ..
done

for repo in ${independent[@]}; do
    echo -e "\n>>> $(tput setaf 3)Handling $repo$(tput sgr0)"

    cd $repo
    git checkout $branch

    if [[ $action == delete ]]; then
        git tag -d $tag_name || true
        git push origin --delete $tag_name || true
    elif [[ $action == release ]]; then
        if [[ $repo == @(kernel_manifest-5.10|kernel_manifest-5.15|kernel_manifest-bluejay|kernel_manifest-coral|kernel_manifest-lynx|kernel_manifest-pantah|kernel_manifest-redbull|kernel_manifest-raviole|kernel_manifest-tangorpro) ]]; then
            git checkout -B tmp
            sed -i s%refs/heads/$base_branch%refs/tags/$tag_name% default.xml
            git commit default.xml -m $tag_name
            git push -fu origin tmp
        else
            git tag -s $tag_name -m $tag_name
            git push origin $tag_name
        fi
    elif [[ $action == update ]]; then
        if [[ $repo != @(device_google_tangorpro-kernel|kernel_manifest-tangorpro|script) ]]; then
            git checkout $base_branch
            git checkout -B $branch
            git push -fu origin $branch
        fi
    elif [[ $action == push ]]; then
        git push
    fi

    cd ..
done
