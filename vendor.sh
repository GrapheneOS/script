#!/bin/bash

set -o errexit -o nounset -o pipefail

readonly devices=(
    felix
    tangorpro
    lynx
    cheetah
    panther
    bluejay
    raven
    oriole
    barbet
    redfin
    bramble
    sunfish
    coral
    flame
)

declare -Ar releases=(
    [felix]=tq3c.230705.001.c1
    [tangorpro]=tq3a.230705.001.b4
    [lynx]=tq3a.230705.001
    [cheetah]=tq3a.230705.001
    [panther]=tq3a.230705.001
    [bluejay]=tq3a.230705.001
    [raven]=tq3a.230705.001
    [oriole]=tq3a.230705.001
    [barbet]=tq3a.230705.001
    [redfin]=tq3a.230705.001
    [bramble]=tq3a.230705.001
    [sunfish]=tq3a.230705.001
    [coral]=tp1a.221005.002.b2
    [flame]=tp1a.221005.002.b2
)

umask 022

for device in ${devices[@]}; do
    release=${releases[$device]}
    #vendor/adevtool/bin/run download vendor/adevtool/dl/ -d $device -b $release -t factory ota
    #sudo vendor/adevtool/bin/run generate-prep -s vendor/adevtool/dl -b $release vendor/adevtool/config/$device.yml
    sudo vendor/adevtool/bin/run generate-all vendor/adevtool/config/$device.yml -c vendor/state/$device.json -s vendor/adevtool/dl/$device-$release-factory-*.zip -a $(which aapt2)
    sudo vendor/adevtool/bin/run ota-firmware vendor/adevtool/config/$device.yml -f vendor/adevtool/dl/$device-ota-$release-*.zip
done

sudo chown -R $USER:$USER vendor/{adevtool,google_devices}
