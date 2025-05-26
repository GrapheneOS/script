#!/bin/bash

# TODO: Write better bash.
# TODO: Rename this to rebase-all-aosp-forks

set -o errexit -o nounset -o pipefail
source "$(dirname ${BASH_SOURCE[0]})/../common.sh"

rebase() {
  # See repo-fetch-aosp-tags.
  if git log -1 --oneline --decorate | grep grafted
  then
      echo "success, but requires manual handling as clone-depth is set"
      # Create a file so that repo status alerts on this repository.
      touch "temporary-repo-status-marker"
      exit 0
  fi

  # Allows us to run this script multiple times if something went wrong.
  git rebase --abort &>/dev/null || true

  git checkout -q -B "${developer_port_branch}" "${graphene_ref}"
  git_exit=0
  git rebase -q --onto $aosp_tag $aosp_tag_old &>/dev/null || git_exit=$?
  if [[ "${git_exit}" == 1 ]]; then
    echo "success, but requires manual conflict resolution"
    return 0
  elif [[ "${git_exit}" != 0 ]]; then
    # If the rebase never begins due to bad tags then git exits with 128.
    echo_red "fail, unexpected error during rebase"
    exit 1
  fi

  if [[ "${REPO_REMOTE}" == "grapheneos" ]]; then
    if ! git push -q -f my-fork $developer_port_branch &>/dev/null
    then
      echo_red "fail, unexpected error during push"
      exit 2
    fi
    echo "success"
  else
    echo "success, but can't push due to hosted on GitLab"
  fi
}

create_developer_port_branch() {
  if ! git checkout -q -B "${developer_port_branch}" "${graphene_ref}"
  then
    # Most likely a repo was introduced during the manifest port and it did not exist for the previous release. A new
    # kernel, for example.
    echo_red "fail, developer port branch target does not exist"
    exit 3
  fi
  if ! git push -q -f my-fork $developer_port_branch &>/dev/null
  then
    echo_red "fail, unexpected error during push"
    exit 2
  fi
  echo "success"
}

# We can't just check if $REPO_REMOTE == "grapheneos" because not all of our repos are AOSP forks. `repo` project groups
# would allow us to simplify this so that we could just run `repo forall -g aosp-forks`.
for graphene_repo in "${aosp_forks[@]}"; do
  if [[ "${graphene_repo}" == "${REPO_PROJECT}" ]] ; then
    rebase "${graphene_repo}"
    exit 0
  fi
done

# If it's not an aosp_fork but its remote is grapheneos then create a branch such that we can update the grapheneos
# remote in the platform manifest to point to a branch in our own repository.
if [[ "${REPO_REMOTE}" == "grapheneos" ]]; then
  create_developer_port_branch
  exit 0
fi
