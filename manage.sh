#!/bin/bash

set -o nounset

DELETE_TAG=

build_number=
if [[ $# -eq 1 ]]; then
  build_number=$1
elif [[ $# -ne 0 ]]; then
  exit 1
fi

branch=pie
aosp_version=PQ2A.190305.002
aosp_version_real=PQ2A.190305.002
aosp_tag=android-9.0.0_r34

aosp_forks=(
  device_common
  device_google_crosshatch
  device_google_crosshatch-sepolicy
  device_google_marlin
  device_google_muskie
  device_google_taimen
  device_google_wahoo
  #device_linaro_hikey
  platform_art
  platform_bionic
  platform_bootable_recovery
  platform_build
  #platform_build_kati
  #platform_build_soong
  #platform_external_clang
  platform_external_conscrypt
  #platform_external_llvm
  #platform_external_svox
  #platform_external_sqlite
  platform_frameworks_av
  platform_frameworks_base
  #platform_frameworks_ex
  platform_frameworks_native
  #platform_frameworks_opt_net_wifi
  platform_libcore
  platform_manifest
  #platform_packages_apps_Bluetooth
  #platform_packages_apps_Camera2
  #platform_packages_apps_Contacts
  platform_packages_apps_ExactCalculator
  #platform_packages_apps_Gallery2
  platform_packages_apps_Launcher3
  platform_packages_apps_Music
  platform_packages_apps_Nfc
  platform_packages_apps_PackageInstaller
  #platform_packages_apps_QuickSearchBox
  platform_packages_apps_Settings
  platform_packages_inputmethods_LatinIME
  #platform_packages_providers_DownloadProvider
  platform_packages_services_Telephony
  #platform_prebuilts_clang_host_linux-x86
  #platform_system_bt
  platform_system_core
  platform_system_extras
  #platform_system_netd
  platform_system_sepolicy
  #platform_test_vts-testcase_kernel
)

declare -A kernels=(
  #[google_marlin]=android-9.0.0_r0.64 # March 2019
  #[google_wahoo]=android-9.0.0_r0.65 # March 2019
  #[google_crosshatch]=android-9.0.0_r0.66 # March 2019
  #[linaro_hikey]=dc721a4ac71d
)

independent=(
  android-prepare-vendor
  #branding
  chromium_build
  chromium_patches
  hardened_malloc
  platform_external_chromium
  #platform_external_Etar-Calendar
  #platform_external_F-Droid
  #platform_external_offline-calendar
  #platform_external_talkback
  #platform_packages_apps_Backup
  #platform_packages_apps_F-Droid_privileged-extension
  #platform_packages_apps_PdfViewer
  platform_packages_apps_Updater
  script
  vendor_linaro
)

for repo in "${aosp_forks[@]}"; do
  echo -e "\n>>> $(tput setaf 3)Handling $repo$(tput sgr0)"

  cd $repo || exit 1

  git checkout $branch || exit 1

  if [[ -n $DELETE_TAG ]]; then
    git tag -d $DELETE_TAG
    git push origin :refs/tags/$DELETE_TAG
    cd .. || exit 1
    continue
  fi

  if [[ -n $build_number ]]; then
    if [[ $repo == platform_manifest ]]; then
      git checkout -B tmp || exit 1
      sed -i s%refs/heads/$branch%refs/tags/$aosp_version.$build_number% default.xml || exit 1
      git commit default.xml -m $aosp_version.$build_number || exit 1
    elif [[ $aosp_version != $aosp_version_real && $repo == platform_build ]]; then
      git checkout -B tmp || exit 1
      sed -i s/$aosp_version_real/$aosp_version/ core/build_id.mk
      git commit core/build_id.mk -m $aosp_version.$build_number || exit 1
    fi

    git tag -s $aosp_version.$build_number -m $aosp_version.$build_number || exit 1
    git push origin $aosp_version.$build_number || exit 1

    if [[ $repo == platform_manifest ]]; then
      git checkout $branch || exit 1
      git branch -D tmp || exit 1
    fi
  else
    git fetch upstream --tags || exit 1

    git pull --rebase upstream $aosp_tag || exit 1
    git push -f || exit 1
  fi

  cd .. || exit 1
done

for kernel in ${!kernels[@]}; do
  echo -e "\n>>> $(tput setaf 3)Handling kernel_$kernel$(tput sgr0)"

  cd kernel_$kernel || exit 1
  git checkout $branch || exit 1

  if [[ -n $DELETE_TAG ]]; then
    git tag -d $DELETE_TAG
    git push origin :refs/tags/$DELETE_TAG
    cd .. || exit 1
    continue
  fi

  if [[ -n $build_number ]]; then
    git tag -s $aosp_version.$build_number -m $aosp_version.$build_number || exit 1
    git push origin $aosp_version.$build_number || exit 1
  else
    git fetch upstream --tags || exit 1
    kernel_tag=${kernels[$kernel]}
    if [[ -z $kernel_tag ]]; then
      cd .. || exit 1
      continue
    fi
    if [[ $kernel == google_marlin || $kernel == google_wahoo ]]; then
      git checkout $branch-stable-base || exit 1
    fi
    git rebase $kernel_tag || exit 1
    git push -f || exit 1
    if [[ $kernel == google_marlin || $kernel == google_wahoo ]]; then
      git checkout $branch || exit 1
      git rebase $branch-stable-base || exit 1
      git push -f || exit 1
    fi
  fi

  cd .. || exit 1
done

for repo in ${independent[@]}; do
  echo -e "\n>>> $(tput setaf 3)Handling $repo$(tput sgr0)"

  cd $repo || exit 1
  git checkout $branch || exit 1

  if [[ -n $DELETE_TAG ]]; then
    git tag -d $DELETE_TAG
    git push origin :refs/tags/$DELETE_TAG
    cd .. || exit 1
    continue
  fi

  if [[ -n $build_number ]]; then
    git tag -s $aosp_version.$build_number -m $aosp_version.$build_number || exit 1
    git push origin $aosp_version.$build_number || exit 1
  else
    git push -f || exit 1
  fi

  cd .. || exit 1
done
