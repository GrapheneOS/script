#!/bin/bash

set -o errexit -o nounset -o pipefail

source "$(dirname ${BASH_SOURCE[0]})/common.sh"

[[ $# -eq 1 ]] || user_error "expected 1 argument: BUILD_NUMBER"

read -rp "Enter key passphrase (empty if none): " -s password
echo
export password

chrt -b -p 0 $$

export TMPDIR="${OUT:-$PWD/delta-generation}"

parallel -j4 -q script/generate-release.sh ::: stallion rango mustang blazer frankel tegu comet komodo caiman tokay akita husky shiba felix tangorpro lynx cheetah panther bluejay raven oriole ::: $1
