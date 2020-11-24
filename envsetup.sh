umask 022
alias which='command -v'
source build/envsetup.sh

export LANG=en_US.UTF-8
export _JAVA_OPTIONS=-XX:-UsePerfData
export BUILD_DATETIME=$(cat out/build_date.txt 2>/dev/null || date -u +%s)
echo "BUILD_DATETIME=$BUILD_DATETIME"
export BUILD_NUMBER=$(cat out/soong/build_number.txt 2>/dev/null || date -u -d @$BUILD_DATETIME +%Y.%m.%d.%H)
echo "BUILD_NUMBER=$BUILD_NUMBER"
export DISPLAY_BUILD_NUMBER=true
export BUILD_USERNAME=grapheneos
export BUILD_HOSTNAME=grapheneos
