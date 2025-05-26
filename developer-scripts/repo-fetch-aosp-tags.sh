#!/bin/bash

# TODO: Write better bash.

set -o errexit -o nounset -o pipefail
source "$(dirname ${BASH_SOURCE[0]})/../common.sh"

fetch_aosp_tags() {
  # If clone-depth="1" is set in manifest then the commit will be grafted. Don't fetch tags. These are typically
  # prebuilts where our additions need to be handled manually. Even if they aren't prebuilt, we don' want to rebase
  # without full history.
  if git log -1 --oneline --decorate | grep grafted
  then
    echo "success, but skipping as repository has clone-depth set"
    exit 0
  fi

  git_exit=0
  if ! git fetch upstream --tags &>/dev/null
  then
    echo_red "fail"
    exit 1
  else
    echo "success"
  fi
}

# We can't just check if $REPO_REMOTE == "grapheneos" because not all of our repos are AOSP forks. `repo` project groups
# would allow us to simplify this so that we could just run `repo forall -g aosp-forks`.
for graphene_repo in "${aosp_forks[@]}"; do
  if [[ "${graphene_repo}" == "${REPO_PROJECT}" ]] ; then
    fetch_aosp_tags "${graphene_repo}"
    exit 0
  fi
done

