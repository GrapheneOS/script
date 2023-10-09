#!/bin/bash

set -o errexit -o nounset -o pipefail

source "$(dirname ${BASH_SOURCE[0]})/common.sh"

if [[ $# -ne 1 ]]; then
    user_error "expected 1 argument"
fi

repo=${1%/}
local_repo=${repo//\//_}

upstream="https://android.googlesource.com/$repo"

git clone $upstream -b $aosp_tag
mv $(basename $repo) $local_repo
cd $local_repo
git checkout -b $branch
git remote add upstream $upstream
git fetch upstream --tags
git remote rm origin
gh repo create --public --push --source . GrapheneOS/$local_repo -h https://grapheneos.org/ --disable-issues --disable-wiki
gh repo edit --enable-projects=false --enable-merge-commit=false
gh repo view --web
