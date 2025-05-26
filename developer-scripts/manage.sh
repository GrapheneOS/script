#!/bin/bash

set -o errexit -o nounset -o pipefail
source "$(dirname ${BASH_SOURCE[0]})/../common.sh"

readonly script_dir=$(dirname "$(realpath ${BASH_SOURCE[0]})")

[[ ! $# -eq 1 ]] && user_error "expected 1 argument, add-aosp-remotes|fetch-aosp-tags|fork-all-graphene|rebase-all-graphene|get-all-graphene-paths"
readonly action=$1

if [[ $action == "add-aosp-remotes" ]]; then
  repo forall -v -e -p -c "${script_dir}/repo-add-aosp-remotes.sh"
elif [[ $action == "fetch-aosp-tags" ]]; then
    repo forall -v -e -p -c "${script_dir}/repo-fetch-aosp-tags.sh"
elif [[ $action == "fork-all-graphene" ]]; then
  repo forall -v -e -p -c "${script_dir}/repo-fork-all-graphene.sh"
elif [[ $action == "rebase-all-graphene" ]]; then
  repo forall -v -e -p -c "${script_dir}/repo-rebase-all-graphene.sh"
elif [[ $action == "get-all-graphene-paths" ]]; then
    repo forall -v -e -c "${script_dir}/repo-get-all-graphene-paths.sh"
else
  user_error "unrecognized action, expected add-aosp-remotes|fetch-aosp-tags|fork-all-graphene|rebase-all-graphene|get-all-graphene-paths"
fi

