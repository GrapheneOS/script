source build/envsetup.sh

export LANG=en_US.UTF-8
export _JAVA_OPTIONS=-XX:-UsePerfData
export BUILD_NUMBER=$(cat out/build_number.txt 2>/dev/null || date -u +%Y.%m.%d.%H)
echo "BUILD_NUMBER=$BUILD_NUMBER"
export DISPLAY_BUILD_NUMBER=true
chrt -b -p 0 $$
export PATH="$PWD/script/bin:$PATH"
