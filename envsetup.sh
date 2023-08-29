umask 022
alias which='command -v'
alias adevtool='vendor/adevtool/bin/run'
alias adto='vendor/adevtool/bin/run'
source build/envsetup.sh

export LANG=C.UTF-8
export _JAVA_OPTIONS=-XX:-UsePerfData
export BUILD_DATETIME=$(cat out/build_date.txt 2>/dev/null || date -u +%s)
echo "BUILD_DATETIME=$BUILD_DATETIME"
export BUILD_NUMBER=$(cat out/soong/build_number.txt 2>/dev/null || date -u -d @$BUILD_DATETIME +%Y%m%d00)
echo "BUILD_NUMBER=$BUILD_NUMBER"
export DISPLAY_BUILD_NUMBER=true
export BUILD_USERNAME=grapheneos
export BUILD_HOSTNAME=grapheneos
