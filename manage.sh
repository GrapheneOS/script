#!/bin/bash

set -o errexit -o nounset -o pipefail

source "$(dirname ${BASH_SOURCE[0]})/common.sh"

[[ $# -eq 0 ]] && user_error "expected action as argument"
readonly action=$1

if [[ $action == @(push|fetch|update|default) ]]; then
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
    device_google_akita
    device_google_bluejay
    device_google_caimito
    device_google_comet
    device_google_felix
    device_google_gs-common
    device_google_gs101
    device_google_gs101-sepolicy
    device_google_gs201
    device_google_gs201-sepolicy
    device_google_lynx
    device_google_pantah
    device_google_raviole
    device_google_shusky
    device_google_tangorpro
    device_google_zuma
    device_google_zuma-sepolicy
    device_google_zumapro
    device_google_zumapro-sepolicy
    kernel_configs
    platform_art
    platform_bionic
    platform_bootable_recovery
    platform_build
    platform_build_release
    platform_build_soong
    platform_development
    platform_external_boringssl
    platform_external_conscrypt
    platform_external_selinux
    platform_frameworks_av
    platform_frameworks_base
    platform_frameworks_libs_systemui
    platform_frameworks_native
    platform_frameworks_opt_net_wifi
    platform_frameworks_opt_telephony
    platform_hardware_google_pixel
    platform_hardware_google_pixel-sepolicy
    platform_hardware_interfaces
    platform_libcore
    platform_manifest
    platform_packages_apps_Calendar
    platform_packages_apps_CellBroadcastReceiver
    platform_packages_apps_Contacts
    platform_packages_apps_Dialer
    platform_packages_apps_DocumentsUI
    platform_packages_apps_EmergencyInfo
    platform_packages_apps_Gallery2
    platform_packages_apps_Launcher3
    platform_packages_apps_Messaging
    platform_packages_apps_Nfc
    platform_packages_apps_Settings
    platform_packages_apps_SettingsIntelligence
    platform_packages_apps_StorageManager
    platform_packages_apps_ThemePicker
    platform_packages_apps_WallpaperPicker2
    platform_packages_inputmethods_LatinIME
    platform_packages_modules_adb
    platform_packages_modules_Bluetooth
    platform_packages_modules_common
    platform_packages_modules_ConfigInfrastructure
    platform_packages_modules_Connectivity
    platform_packages_modules_DnsResolver
    platform_packages_modules_HealthFitness
    platform_packages_modules_NetworkStack
    platform_packages_modules_Permission
    platform_packages_modules_RemoteKeyProvisioning
    platform_packages_modules_Uwb
    platform_packages_modules_Virtualization
    platform_packages_modules_Wifi
    platform_packages_providers_ContactsProvider
    platform_packages_providers_DownloadProvider
    platform_packages_providers_MediaProvider
    platform_packages_services_Mms
    platform_packages_services_Telecomm
    platform_packages_services_Telephony
    platform_prebuilts_abi-dumps_platform
    platform_prebuilts_abi-dumps_vndk
    platform_system_core
    platform_system_extras
    platform_system_librustutils
    platform_system_logging
    platform_system_netd
    platform_system_sepolicy
    platform_system_vold
)

readonly kernels=(
    kernel_build-gs
    kernel_devices_google_tangorpro
    kernel_gs
    kernel_google-modules_amplifiers-gs
    kernel_google-modules_power_reset-gs
    kernel_google-modules_wlan_bcmdhd_bcm4389
    kernel_google-modules_wlan_syna_dhd43752p

    kernel_build-zuma
    kernel_devices_google_akita
    kernel_devices_google_shusky
    kernel_google-modules_amplifiers-zuma
    kernel_google-modules_power_reset-zuma
    kernel_google-modules_soc_gs
    kernel_google-modules_wlan_bcmdhd_bcm4383
    kernel_google-modules_wlan_bcmdhd_bcm4398

    kernel_build-zumapro
    kernel_devices_google_caimito
    kernel_devices_google_comet
    kernel_google-modules_amplifiers-zumapro
    kernel_google-modules_bms-zumapro
    kernel_google-modules_edgetpu_rio
    kernel_google-modules_gpu-zumapro
    kernel_google-modules_gxp_zuma
    kernel_google-modules_power_reset-zumapro
    kernel_google-modules_soc_gs-zumapro
    kernel_google-modules_wlan_bcmdhd_bcm4390
)

declare -Ar kernel_tags_old=(
    # December 2024
    [kernel_build-gs]=android-15.0.0_r0.35
    [kernel_devices_google_tangorpro]=android-15.0.0_r0.35
    [kernel_gs]=android-15.0.0_r0.35
    [kernel_google-modules_amplifiers-gs]=android-15.0.0_r0.35
    [kernel_google-modules_power_reset-gs]=android-15.0.0_r0.35
    [kernel_google-modules_wlan_bcmdhd_bcm4389]=android-15.0.0_r0.35
    [kernel_google-modules_wlan_syna_dhd43752p]=android-15.0.0_r0.35

    # December 2024
    [kernel_build-zuma]=android-15.0.0_r0.37
    [kernel_devices_google_akita]=android-15.0.0_r0.37
    [kernel_devices_google_shusky]=android-15.0.0_r0.37
    [kernel_google-modules_amplifiers-zuma]=android-15.0.0_r0.37
    [kernel_google-modules_power_reset-zuma]=android-15.0.0_r0.37
    [kernel_google-modules_soc_gs]=android-15.0.0_r0.37
    [kernel_google-modules_wlan_bcmdhd_bcm4383]=android-15.0.0_r0.37
    [kernel_google-modules_wlan_bcmdhd_bcm4398]=android-15.0.0_r0.37

    # December 2024
    [kernel_build-zumapro]=android-15.0.0_r0.39
    [kernel_devices_google_caimito]=android-15.0.0_r0.39
    [kernel_devices_google_comet]=android-15.0.0_r0.39
    [kernel_google-modules_amplifiers-zumapro]=android-15.0.0_r0.39
    [kernel_google-modules_bms-zumapro]=android-15.0.0_r0.39
    [kernel_google-modules_edgetpu_rio]=android-15.0.0_r0.39
    [kernel_google-modules_gpu-zumapro]=android-15-qpr2-beta-1_r0.9
    [kernel_google-modules_gxp_zuma]=android-15.0.0_r0.39
    [kernel_google-modules_power_reset-zumapro]=android-15.0.0_r0.39
    [kernel_google-modules_soc_gs-zumapro]=android-15.0.0_r0.39
    [kernel_google-modules_wlan_bcmdhd_bcm4390]=android-15.0.0_r0.39
)

declare -Ar kernel_tags=(
    # December 2024
    [kernel_build-gs]=android-15.0.0_r0.35
    [kernel_devices_google_tangorpro]=android-15.0.0_r0.35
    [kernel_gs]=android-15.0.0_r0.35
    [kernel_google-modules_amplifiers-gs]=android-15.0.0_r0.35
    [kernel_google-modules_power_reset-gs]=android-15.0.0_r0.35
    [kernel_google-modules_wlan_bcmdhd_bcm4389]=android-15.0.0_r0.35
    [kernel_google-modules_wlan_syna_dhd43752p]=android-15.0.0_r0.35

    # December 2024
    [kernel_build-zuma]=android-15.0.0_r0.37
    [kernel_devices_google_akita]=android-15.0.0_r0.37
    [kernel_devices_google_shusky]=android-15.0.0_r0.37
    [kernel_google-modules_amplifiers-zuma]=android-15.0.0_r0.37
    [kernel_google-modules_power_reset-zuma]=android-15.0.0_r0.37
    [kernel_google-modules_soc_gs]=android-15.0.0_r0.37
    [kernel_google-modules_uwb_qorvo_qm35]=android-15.0.0_r0.37
    [kernel_google-modules_wlan_bcmdhd_bcm4383]=android-15.0.0_r0.37
    [kernel_google-modules_wlan_bcmdhd_bcm4398]=android-15.0.0_r0.37

    # December 2024
    [kernel_build-zumapro]=android-15.0.0_r0.39
    [kernel_devices_google_caimito]=android-15.0.0_r0.39
    [kernel_devices_google_comet]=android-15.0.0_r0.39
    [kernel_google-modules_amplifiers-zumapro]=android-15.0.0_r0.39
    [kernel_google-modules_bms-zumapro]=android-15.0.0_r0.39
    [kernel_google-modules_edgetpu_rio]=android-15.0.0_r0.39
    [kernel_google-modules_gpu-zumapro]=android-15-qpr2-beta-1_r0.9
    [kernel_google-modules_gxp_zuma]=android-15.0.0_r0.39
    [kernel_google-modules_power_reset-zumapro]=android-15.0.0_r0.39
    [kernel_google-modules_soc_gs-zumapro]=android-15.0.0_r0.39
    [kernel_google-modules_wlan_bcmdhd_bcm4390]=android-15.0.0_r0.39
)

readonly independent=(
    adevtool
    branding
    device_google_akita-kernels_5.15
    device_google_bluejay-kernels_5.10
    device_google_caimito-kernels_6.1
    device_google_comet-kernels_6.1
    device_google_felix-kernels_5.10
    device_google_lynx-kernels_5.10
    device_google_pantah-kernels_5.10
    device_google_raviole-kernels_5.10
    device_google_shusky-kernels_5.15
    device_google_tangorpro-kernels_5.10
    hardened_malloc
    kernel_common-5.10
    kernel_common-5.15
    kernel_common-6.1
    kernel_common-6.6
    kernel_manifest-5.10
    kernel_manifest-5.15
    kernel_manifest-6.1
    kernel_manifest-6.6
    kernel_manifest-gs
    kernel_manifest-zuma
    kernel_manifest-zumapro
    platform_external_AppCompatConfig
    platform_external_AppStore
    platform_external_Auditor
    platform_external_Camera
    platform_external_GmsCompatConfig
    platform_external_Info
    platform_external_PdfViewer
    platform_external_seedvault
    platform_external_talkback
    platform_external_vanadium
    platform_packages_apps_AppCompatConfig
    platform_packages_apps_CarrierConfig2
    platform_packages_apps_DeskClock # temporarily based on AOSP 11 instead of AOSP 13
    platform_packages_apps_ExactCalculator
    platform_packages_apps_GmsCompat
    platform_packages_apps_LogViewer
    platform_packages_apps_SetupWizard2
    platform_packages_apps_Updater
    script
    vendor_state
)

if [[ $OFFICIAL_BUILD = true ]]; then
    export GIT_AUTHOR_NAME=GrapheneOS
    export GIT_AUTHOR_EMAIL=contact@grapheneos.org
    export GIT_COMMITTER_NAME=$GIT_AUTHOR_NAME
    export GIT_COMMITTER_EMAIL=$GIT_AUTHOR_EMAIL
fi

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
        git rebase --onto $aosp_tag $aosp_tag_old
        git push -f
    elif [[ $action == push ]]; then
        git push
    elif [[ $action == fetch ]]; then
        git fetch upstream --tags
    elif [[ $action == default ]]; then
        if [[ $repo != platform_packages_modules_Connectivity ]]; then
            gh repo edit GrapheneOS/$repo --default-branch $branch
        fi
    fi

    cd ..
done

for repo in ${kernels[@]}; do
    echo -e "\n>>> $(tput setaf 3)Handling $repo$(tput sgr0)"

    cd $repo
    git checkout $branch

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
    elif [[ $action == default ]]; then
        gh repo edit GrapheneOS/$repo --default-branch $branch
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
        if [[ $repo == @(kernel_manifest-5.10|kernel_manifest-5.15|kernel_manifest-6.1|kernel_manifest-6.6|kernel_manifest-gs|kernel_manifest-zuma|kernel_manifest-zumapro) ]]; then
            git checkout -B tmp
            sed -i s%refs/heads/$branch%refs/tags/$tag_name% default.xml
            git commit default.xml -m $tag_name
            git push -fu origin tmp
        else
            git tag -s $tag_name -m $tag_name
            git push origin $tag_name
        fi
    elif [[ $action == push ]]; then
        git push
    elif [[ $action == default ]]; then
        if [[ $repo != platform_external_vanadium ]]; then
            gh repo edit GrapheneOS/$repo --default-branch $branch
        fi
    fi

    cd ..
done
