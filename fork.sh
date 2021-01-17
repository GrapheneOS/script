#!/bin/bash

set -o errexit -o nounset -o pipefail

source "$(dirname ${BASH_SOURCE[0]})/common.sh"

if [[ $# -ne 1 ]]; then
    user_error "expected 1 argument"
fi

repo=$1
local_repo=${repo//\//_}

branch=11
aosp_tag=android-11.0.0_r27
upstream="https://android.googlesource.com/$repo"

git clone $upstream -b $aosp_tag
mv $(basename $repo) $local_repo
cd $local_repo
git checkout -b 11
git remote add upstream $upstream
git fetch upstream --tags
git remote rm origin
hub create GrapheneOS/$local_repo -h https://grapheneos.org/
git push -u origin 11
xdg-open https://github.com/GrapheneOS/$local_repo
