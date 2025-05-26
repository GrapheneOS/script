#!/bin/bash

# TODO: Write better bash.

set -o errexit -o nounset -o pipefail
source "$(dirname ${BASH_SOURCE[0]})/../common.sh"

readonly aosp_repo_base="https://android.googlesource.com/"

add_remote() {
  aosp_repo="${1//_/\/}"
  aosp_remote="${aosp_repo_base}${aosp_repo}"

  git_exit=0
  git remote add upstream $aosp_remote &>/dev/null || git_exit=$?
  if [[ "${git_exit}" == 3 ]]; then
    echo "success, already exists"
  elif [[ "${git_exit}" != 0 ]]; then
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
    add_remote "${graphene_repo}"
    exit 0
  fi
done

