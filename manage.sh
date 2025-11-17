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
        git tag -s $tag_name -m $tag_name
        git push origin $tag_name
    elif [[ $action == update ]]; then
        git fetch upstream --tags
        git rebase --onto $aosp_tag $aosp_tag_old
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
        if [[ $repo == @(kernel_manifest-pixel|kernel_manifest-6.1|kernel_manifest-6.6|kernel_manifest-6.12|platform_manifest) ]]; then
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
        if [[ $repo != @(hardened_malloc|kernel_pixel|kernel_pixel_muzel|platform_external_vanadium) ]]; then
            gh repo edit GrapheneOS/$repo --default-branch $branch
        fi
    fi

    cd ..
done
