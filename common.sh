readonly branch=16
readonly aosp_tag_old=android-16.0.0_r1
readonly aosp_tag=android-16.0.0_r1

user_error() {
    echo $1 >&2
    exit 1
}

readonly aosp_forks=(
    device_common
    device_generic_goldfish
    platform_art
    platform_bionic
    platform_bootable_recovery
    platform_build
    platform_build_release
    platform_build_soong
    platform_development
    platform_external_conscrypt
    platform_external_robolectric
    platform_external_selinux
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
    platform_packages_apps_Settings
    platform_packages_apps_SettingsIntelligence
    platform_packages_apps_StorageManager
    platform_packages_apps_ThemePicker
    platform_packages_apps_WallpaperPicker2
    platform_packages_inputmethods_LatinIME
    platform_packages_modules_adb
    platform_packages_modules_AppSearch
    platform_packages_modules_Bluetooth
    platform_packages_modules_common
    platform_packages_modules_ConfigInfrastructure
    platform_packages_modules_Connectivity
    platform_packages_modules_DnsResolver
    platform_packages_modules_HealthFitness
    platform_packages_modules_NetworkStack
    platform_packages_modules_Nfc
    platform_packages_modules_Permission
    platform_packages_modules_RemoteKeyProvisioning
    platform_packages_modules_StatsD
    platform_packages_modules_Uwb
    platform_packages_modules_Virtualization
    platform_packages_modules_Wifi
    platform_packages_providers_ContactsProvider
    platform_packages_providers_DownloadProvider
    platform_packages_providers_MediaProvider
    platform_packages_services_Mms
    platform_packages_services_Telecomm
    platform_packages_services_Telephony
    platform_system_ca-certificates
    platform_system_core
    platform_system_extras
    platform_system_logging
    platform_system_netd
    platform_system_sepolicy
    platform_system_vold
    platform_tools_metalava
)

readonly kernels=(
    kernel_build

    kernel_devices_google_common

    kernel_devices_google_raviole
    kernel_devices_google_bluejay
    kernel_devices_google_pantah
    kernel_devices_google_lynx
    kernel_devices_google_tangorpro
    kernel_devices_google_felix
    kernel_devices_google_shusky
    kernel_devices_google_akita
    kernel_devices_google_caimito
    kernel_devices_google_comet
    kernel_devices_google_tegu

    kernel_google-modules_amplifiers
    kernel_google-modules_bms
    kernel_google-modules_edgetpu_rio
    kernel_google-modules_gxp_gs201
    kernel_google-modules_gxp_zuma
    kernel_google-modules_power_reset
    kernel_google-modules_soc_gs
    kernel_google-modules_wlan_bcmdhd_bcm4383
    kernel_google-modules_wlan_bcmdhd_bcm4389
    kernel_google-modules_wlan_bcmdhd_bcm4390
    kernel_google-modules_wlan_bcmdhd_bcm4398
    kernel_google-modules_wlan_syna_dhd43752p
)

declare -Ar kernel_tags_old=(
    [kernel_build]=android-16.0.0_r0.0

    [kernel_devices_google_common]=android-16.0.0_r0.0

    [kernel_devices_google_raviole]=android-16.0.0_r0.0
    [kernel_devices_google_bluejay]=android-16.0.0_r0.0
    [kernel_devices_google_pantah]=android-16.0.0_r0.0
    [kernel_devices_google_lynx]=android-16.0.0_r0.0
    [kernel_devices_google_tangorpro]=android-16.0.0_r0.0
    [kernel_devices_google_felix]=android-16.0.0_r0.0
    [kernel_devices_google_shusky]=android-16.0.0_r0.0
    [kernel_devices_google_akita]=android-16.0.0_r0.0
    [kernel_devices_google_caimito]=android-16.0.0_r0.0
    [kernel_devices_google_comet]=android-16.0.0_r0.0
    [kernel_devices_google_tegu]=android-16.0.0_r0.0

    [kernel_google-modules_amplifiers]=android-16.0.0_r0.0
    [kernel_google-modules_bms]=android-16.0.0_r0.0
    [kernel_google-modules_edgetpu_rio]=android-16.0.0_r0.0
    [kernel_google-modules_gxp_gs201]=android-16.0.0_r0.0
    [kernel_google-modules_gxp_zuma]=android-16.0.0_r0.0
    [kernel_google-modules_power_reset]=android-16.0.0_r0.0
    [kernel_google-modules_soc_gs]=android-16.0.0_r0.0
    [kernel_google-modules_wlan_bcmdhd_bcm4383]=android-16.0.0_r0.0
    [kernel_google-modules_wlan_bcmdhd_bcm4389]=android-16.0.0_r0.0
    [kernel_google-modules_wlan_bcmdhd_bcm4390]=android-16.0.0_r0.0
    [kernel_google-modules_wlan_bcmdhd_bcm4398]=android-16.0.0_r0.0
    [kernel_google-modules_wlan_syna_dhd43752p]=android-16.0.0_r0.0
)

declare -Ar kernel_tags=(
    [kernel_build]=android-16.0.0_r0.0

    [kernel_devices_google_common]=android-16.0.0_r0.0

    [kernel_devices_google_raviole]=android-16.0.0_r0.0
    [kernel_devices_google_bluejay]=android-16.0.0_r0.0
    [kernel_devices_google_pantah]=android-16.0.0_r0.0
    [kernel_devices_google_lynx]=android-16.0.0_r0.0
    [kernel_devices_google_tangorpro]=android-16.0.0_r0.0
    [kernel_devices_google_felix]=android-16.0.0_r0.0
    [kernel_devices_google_shusky]=android-16.0.0_r0.0
    [kernel_devices_google_akita]=android-16.0.0_r0.0
    [kernel_devices_google_caimito]=android-16.0.0_r0.0
    [kernel_devices_google_comet]=android-16.0.0_r0.0
    [kernel_devices_google_tegu]=android-16.0.0_r0.0

    [kernel_google-modules_amplifiers]=android-16.0.0_r0.0
    [kernel_google-modules_bms]=android-16.0.0_r0.0
    [kernel_google-modules_edgetpu_rio]=android-16.0.0_r0.0
    [kernel_google-modules_gxp_gs201]=android-16.0.0_r0.0
    [kernel_google-modules_gxp_zuma]=android-16.0.0_r0.0
    [kernel_google-modules_power_reset]=android-16.0.0_r0.0
    [kernel_google-modules_soc_gs]=android-16.0.0_r0.0
    [kernel_google-modules_wlan_bcmdhd_bcm4383]=android-16.0.0_r0.0
    [kernel_google-modules_wlan_bcmdhd_bcm4389]=android-16.0.0_r0.0
    [kernel_google-modules_wlan_bcmdhd_bcm4390]=android-16.0.0_r0.0
    [kernel_google-modules_wlan_bcmdhd_bcm4398]=android-16.0.0_r0.0
    [kernel_google-modules_wlan_syna_dhd43752p]=android-16.0.0_r0.0
)

readonly independent=(
    device_google_akita
    device_google_akita-sepolicy
    device_google_bluejay
    device_google_bluejay-sepolicy
    device_google_caimito
    device_google_caimito-sepolicy
    device_google_comet
    device_google_comet-sepolicy
    device_google_felix
    device_google_felix-sepolicy
    device_google_gs-common
    device_google_gs101
    device_google_gs101-sepolicy
    device_google_gs201
    device_google_gs201-sepolicy
    device_google_lynx
    device_google_lynx-sepolicy
    device_google_pantah
    device_google_pantah-sepolicy
    device_google_raviole
    device_google_shusky
    device_google_shusky-sepolicy
    device_google_tangorpro
    device_google_tangorpro-sepolicy
    device_google_tegu
    device_google_tegu-sepolicy
    device_google_zuma
    device_google_zuma-sepolicy
    device_google_zumapro
    device_google_zumapro-sepolicy

    adevtool
    branding
    device_google_akita-kernels_6.1
    device_google_bluejay-kernels_6.1
    device_google_caimito-kernels_6.1
    device_google_comet-kernels_6.1
    device_google_felix-kernels_6.1
    device_google_lynx-kernels_6.1
    device_google_pantah-kernels_6.1
    device_google_raviole-kernels_6.1
    device_google_shusky-kernels_6.1
    device_google_tangorpro-kernels_6.1
    device_google_tegu-kernels_6.1
    hardened_malloc
    kernel_common-6.1
    kernel_common-6.6
    kernel_common-6.12
    kernel_manifest-6.1
    kernel_manifest-6.6
    kernel_manifest-pixel
    platform_external_AppCompatConfig
    platform_external_AppStore
    platform_external_Auditor
    platform_external_Camera
    platform_external_GmsCompatConfig
    platform_external_Info
    platform_external_Messaging
    platform_external_PdfViewer
    platform_external_talkback
    platform_external_vanadium
    platform_packages_apps_AppCompatConfig
    platform_packages_apps_CarrierConfig2
    platform_packages_apps_DeskClock # temporarily based on AOSP 11 instead of AOSP 13
    platform_packages_apps_ExactCalculator
    platform_packages_apps_GmsCompat
    platform_packages_apps_LogViewer
    platform_packages_apps_NetworkLocation
    platform_packages_apps_Seedvault
    platform_packages_apps_SetupWizard2
    platform_packages_apps_Updater
    script
    vendor_state
)
